param(
  [Parameter(Mandatory = $true)][string]$StoreVersion,
  [string]$BundleDir = 'build/windows/x64/runner/Release',
  [string]$OutputDir = 'dist/windows-store'
)
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$root = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$prepare = Join-Path $root 'scripts/windows_store.py'
$normalized = & python $prepare --version $StoreVersion --normalized
if ($LASTEXITCODE -ne 0) { throw 'Invalid Microsoft Store version' }
$StoreVersion = $normalized
$bundle = (Resolve-Path -LiteralPath $BundleDir).Path
if (!(Test-Path -LiteralPath (Join-Path $bundle 'marker.exe'))) { throw 'Release runner not found' }
# MSIX version is independent of the application version in pubspec.yaml.

# Ship the Release CRT app-locally; do not require an MSI prerequisite installer.
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($LASTEXITCODE -ne 0 -or !$vs) { throw 'Visual C++ installation not found' }
$crt = Get-ChildItem -Path (Join-Path $vs 'VC/Redist/MSVC') -Directory |
  Sort-Object { [version]$_.Name } -Descending |
  ForEach-Object { Get-ChildItem -Path (Join-Path $_.FullName 'x64/Microsoft.VC*.CRT') -Directory } |
  Select-Object -First 1
if (!$crt) { throw 'Visual C++ x64 Release CRT not found' }
Get-ChildItem -LiteralPath $crt.FullName -Filter '*.dll' | Copy-Item -Destination $bundle

$kits = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits/10/bin'
$makeappx = Get-ChildItem -LiteralPath $kits -Directory |
  Where-Object { $_.Name -match '^10\.0\.\d+\.\d+$' } |
  Sort-Object { [version]$_.Name } -Descending |
  ForEach-Object { Join-Path $_.FullName 'x64/makeappx.exe' } |
  Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
  Select-Object -First 1
if (!$makeappx) { throw 'Windows SDK MakeAppx.exe not found' }
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$output = (Resolve-Path -LiteralPath $OutputDir).Path
$staging = Join-Path ([IO.Path]::GetTempPath()) ('marker-store-' + [guid]::NewGuid())
$package = Join-Path $output "Marker-Store-x64-$StoreVersion.msix"
if (Test-Path -LiteralPath $package) { throw "Refusing to overwrite existing Store package: $package" }
try {
  & python $prepare --version $StoreVersion --bundle $bundle --output $staging
  if ($LASTEXITCODE -ne 0) { throw 'Store staging validation failed' }
  # Keep semantic/schema validation enabled. This package is intentionally unsigned.
  & $makeappx pack /d $staging /p $package /h SHA256
  if ($LASTEXITCODE -ne 0) { throw "MakeAppx failed: $LASTEXITCODE" }
  & python $prepare --version $StoreVersion --verify $package
  if ($LASTEXITCODE -ne 0) { throw 'Final MSIX identity/payload validation failed' }
  Copy-Item (Join-Path $staging 'AppxManifest.xml') (Join-Path $output 'AppxManifest.xml')
  Copy-Item (Join-Path $root 'windows/store/identity.json') $output
  Copy-Item (Join-Path $root 'docs/MICROSOFT_STORE.md') $output
  Write-Host "Store upload package: $package"
} finally {
  if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}
