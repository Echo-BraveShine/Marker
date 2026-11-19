$ErrorActionPreference = 'Stop'
$toolsRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$bundle = (Resolve-Path 'build/windows/x64/runner/Release').Path
# A compiled runner alone is not a distributable Flutter application.
foreach ($required in 'flutter_windows.dll', 'data/icudtl.dat', 'data/app.so', 'data/flutter_assets/AssetManifest.bin') {
  $path = Join-Path $bundle $required
  if (-not (Test-Path $path -PathType Leaf) -or (Get-Item $path).Length -eq 0) {
    throw "Incomplete Flutter bundle: missing $required"
  }
}
$exe = Get-Item "$bundle/marker.exe"
$numeric = "$($exe.VersionInfo.ProductMajorPart).$($exe.VersionInfo.ProductMinorPart).$($exe.VersionInfo.ProductBuildPart).$($exe.VersionInfo.ProductPrivatePart)"
if ($numeric -ne "$env:EXPECTED_VERSION.$env:EXPECTED_BUILD" -or
    $exe.VersionInfo.ProductVersion -ne "$env:EXPECTED_VERSION+$env:EXPECTED_BUILD" -or
    $exe.VersionInfo.FileVersion -ne "$env:EXPECTED_VERSION+$env:EXPECTED_BUILD") { throw "Unexpected app version: $numeric" }
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (-not (Test-Path $vswhere)) { throw 'vswhere not found' }
$vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (-not $vs) { throw 'Visual Studio C++ tools not found' }
$crt = Get-ChildItem "$vs/VC/Redist/MSVC" -Directory |
  Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' } |
  Sort-Object { [version]$_.Name } -Descending |
  ForEach-Object { Get-ChildItem "$($_.FullName)/x64/Microsoft.VC*.CRT" -Directory } |
  Select-Object -First 1
if (-not $crt) { throw 'Visual C++ x64 runtime not found' }
foreach ($dll in 'msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll') {
  Copy-Item (Join-Path $crt.FullName $dll) $bundle
}
New-Item -ItemType Directory -Force dist | Out-Null
$output = (Resolve-Path dist).Path
$compilerCommand = Get-Command ISCC.exe -ErrorAction SilentlyContinue
$compilerCandidates = @(
  $env:INNO_SETUP_COMPILER,
  $compilerCommand.Source,
  (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6/ISCC.exe'),
  (Join-Path $env:ProgramFiles 'Inno Setup 6/ISCC.exe'),
  (Join-Path $env:LOCALAPPDATA 'Programs/Inno Setup 6/ISCC.exe')
)
$iscc = $compilerCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $iscc) { throw 'Inno Setup 6 not found; set INNO_SETUP_COMPILER to ISCC.exe' }
& $iscc "/DAppVersion=$env:EXPECTED_VERSION" "/DBuildNumber=$env:EXPECTED_BUILD" "/DBuildOutput=$bundle" "/O$output" '/FMarker-Windows-x64-Setup' (Join-Path $toolsRoot 'windows/installer/marker.iss')
if ($LASTEXITCODE -ne 0) { throw "Inno Setup failed: $LASTEXITCODE" }
Compress-Archive -Path "$bundle/*" -DestinationPath dist/Marker-windows-x64.zip -Force
if (-not (Test-Path dist/Marker-Windows-x64-Setup.exe)) { throw 'Installer not produced' }

$installer = Get-Item dist/Marker-Windows-x64-Setup.exe
$version = $installer.VersionInfo
$installerNumeric = "$($version.FileMajorPart).$($version.FileMinorPart).$($version.FileBuildPart).$($version.FilePrivatePart)"
if ($installerNumeric -ne "$env:EXPECTED_VERSION.$env:EXPECTED_BUILD" -or
    $version.ProductVersion.TrimEnd() -ne "$env:EXPECTED_VERSION+$env:EXPECTED_BUILD") {
  throw "Unexpected installer version: $installerNumeric / $($version.ProductVersion)"
}

& (Join-Path $PSScriptRoot 'windows-msi.ps1') -BundleDir $bundle -InstallerDir (Join-Path $toolsRoot 'windows/installer') -InstallTest:($env:MARKER_VERIFY_MSI_INSTALL -eq '1')
