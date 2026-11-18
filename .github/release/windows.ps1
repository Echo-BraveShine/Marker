$ErrorActionPreference = 'Stop'
$bundle = (Resolve-Path 'build/windows/x64/runner/Release').Path
$exe = Get-Item "$bundle/marker.exe"
$numeric = "$($exe.VersionInfo.ProductMajorPart).$($exe.VersionInfo.ProductMinorPart).$($exe.VersionInfo.ProductBuildPart).$($exe.VersionInfo.ProductPrivatePart)"
if ($numeric -ne "$env:EXPECTED_VERSION.$env:EXPECTED_BUILD") { throw "Unexpected app version: $numeric" }
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
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
$iscc = Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6/ISCC.exe'
if (-not (Test-Path $iscc)) { throw 'Inno Setup 6 not found' }
& $iscc "/DAppVersion=$env:EXPECTED_VERSION" "/DBuildNumber=$env:EXPECTED_BUILD" "/DBuildOutput=$bundle" "/O$output" '/FMarker-Windows-x64-Setup' windows/installer/marker.iss
if ($LASTEXITCODE -ne 0) { throw "Inno Setup failed: $LASTEXITCODE" }
Compress-Archive -Path "$bundle/*" -DestinationPath dist/Marker-windows-x64.zip -Force
if (-not (Test-Path dist/Marker-Windows-x64-Setup.exe)) { throw 'Installer not produced' }
