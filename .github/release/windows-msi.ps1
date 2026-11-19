param(
    [Parameter(Mandatory)][string]$BundleDir,
    [Parameter(Mandatory)][string]$InstallerDir,
    [switch]$InstallTest
)
$ErrorActionPreference = 'Stop'

$wixVersion = '6.0.2'
$toolDir = Join-Path $env:RUNNER_TEMP "marker-wix-$wixVersion"
New-Item -ItemType Directory -Force dist | Out-Null
if (-not (Test-Path (Join-Path $toolDir 'wix.exe'))) {
    dotnet tool install wix --tool-path $toolDir --version $wixVersion
    if ($LASTEXITCODE -ne 0) { throw 'Installing WiX failed' }
}

# Bind the exact extension DLL; extension caches depend on the working directory.
$extensionRoot = Join-Path $toolDir 'extensions'
$extension = Join-Path $extensionRoot 'WixToolset.UI.wixext/wixext6/WixToolset.UI.wixext.dll'
if (-not (Test-Path $extension)) {
    nuget.exe install WixToolset.UI.wixext -Version $wixVersion -ExcludeVersion -NonInteractive `
        -Source https://api.nuget.org/v3/index.json -OutputDirectory $extensionRoot
    if ($LASTEXITCODE -ne 0) { throw 'Installing WiX UI extension failed' }
}
if (-not (Test-Path $extension)) { throw 'WiX UI extension DLL not found' }

function Test-MarkerMsi([string]$msi, [string]$culture) {
    $installer = New-Object -ComObject WindowsInstaller.Installer
    $database = $installer.OpenDatabase($msi, 0)
    $view = $database.OpenView('SELECT `Property`, `Value` FROM `Property`')
    $view.Execute()
    $properties = @{}
    while ($record = $view.Fetch()) {
        $properties[$record.StringData(1)] = $record.StringData(2)
    }
    $view.Close()
    if ($properties.ProductVersion -ne $env:EXPECTED_VERSION -or
        $properties.MARKER_BUILD_NUMBER -ne $env:EXPECTED_BUILD -or
        $properties.ProductLanguage -ne $(if ($culture -eq 'zh-CN') { '2052' } else { '1033' })) {
        throw "Unexpected MSI version: $($properties.ProductVersion)+$($properties.MARKER_BUILD_NUMBER)"
    }
    $shortcutView = $database.OpenView('SELECT `Icon_`, `IconIndex` FROM `Shortcut` WHERE `Shortcut` = ''MarkerStartMenu''')
    $shortcutView.Execute()
    $shortcut = $shortcutView.Fetch()
    if (-not $shortcut -or $shortcut.StringData(1) -ne 'MarkerShortcut.exe' -or $shortcut.IntegerData(2) -ne 0) {
        throw 'MSI Start Menu shortcut must reference its EXE icon stream'
    }
    $shortcutView.Close()
    $iconView = $database.OpenView('SELECT `Data` FROM `Icon` WHERE `Name` = ''MarkerShortcut.exe''')
    $iconView.Execute()
    $icon = $iconView.Fetch()
    if (-not $icon -or $icon.ReadStream(1, 2, 1) -ne 'MZ') {
        throw 'MSI advertised shortcut icon must contain a PE executable'
    }
    $iconView.Close()
    $modelView = $database.OpenView('SELECT `PropVariantValue` FROM `MsiShortcutProperty` WHERE `PropertyKey` = ''System.AppUserModel.ID''')
    $modelView.Execute()
    $model = $modelView.Fetch()
    if (-not $model -or $model.StringData(1) -ne 'dev.ekko.marker') {
        throw 'MSI Start Menu shortcut AppUserModelID is missing'
    }
    $modelView.Close()
    foreach ($metadataView in $shortcutView, $iconView, $modelView) {
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($metadataView)
    }
    $upgradeView = $database.OpenView('SELECT `Language` FROM `Upgrade`')
    $upgradeView.Execute()
    while ($upgrade = $upgradeView.Fetch()) {
        if (-not [string]::IsNullOrEmpty($upgrade.StringData(1))) {
            throw 'MSI upgrades must detect both Chinese and English installations'
        }
    }
    $upgradeView.Close()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($upgradeView)
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($view)
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($database)
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($installer)

    # Persistent unprivileged runners build and inspect MSI metadata only.
    # Hosted release runners additionally exercise installation and removal.
    if (-not $InstallTest) { return }

    $installDir = Join-Path $env:ProgramFiles 'Marker'
    if ((Test-Path $installDir) -and @(Get-ChildItem $installDir -Recurse -File -Force).Count -gt 0) {
        throw 'MSI smoke test requires a clean install directory; refusing to modify an existing installation'
    }
    $log = Join-Path $env:RUNNER_TEMP "marker-msi-$culture.log"
    $process = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart /L*v `"$log`"" -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Get-Content $log -Tail 100
        throw "Installing MSI failed with code $($process.ExitCode)"
    }
    try {
        $installDir = Join-Path $env:ProgramFiles 'Marker'
        foreach ($file in 'marker.exe', 'flutter_windows.dll', 'vcruntime140.dll', 'data/flutter_assets/AssetManifest.bin') {
            if (-not (Test-Path (Join-Path $installDir $file))) { throw "Missing installed file: $file" }
        }
        $version = (Get-Item (Join-Path $installDir 'marker.exe')).VersionInfo
        if ($version.ProductVersion -ne "$env:EXPECTED_VERSION+$env:EXPECTED_BUILD") {
            throw "Unexpected installed Flutter version: $($version.ProductVersion)"
        }
    } finally {
        $process = Start-Process msiexec.exe -ArgumentList "/x $($properties.ProductCode) /qn /norestart" -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "Uninstalling MSI failed with code $($process.ExitCode)" }
    }

}

$definition = Join-Path $InstallerDir 'marker.wxs'
$productCode = [Guid]::NewGuid().ToString('B')
# Both language variants identify the same product; do not install side by side.
foreach ($culture in 'en-US', 'zh-CN') {
    $name = if ($culture -eq 'en-US') { 'Marker-Windows-x64.msi' } else { 'Marker-Windows-x64-zh-CN.msi' }
    $msi = Join-Path (Get-Location).Path "dist/$name"
    Remove-Item ([IO.Path]::ChangeExtension($msi, '.wixpdb')) -ErrorAction SilentlyContinue
    Push-Location $InstallerDir
    try {
        & "$toolDir/wix.exe" build -arch x64 -pdbtype none -ext $extension `
            -culture $culture -loc (Join-Path $InstallerDir "$culture.wxl") `
            -d "AppVersion=$env:EXPECTED_VERSION" -d "BuildNumber=$env:EXPECTED_BUILD" `
            -d "ProductCode=$productCode" -d "BundleDir=$BundleDir" `
            -bindpath $InstallerDir -o $msi $definition
        if ($LASTEXITCODE -ne 0) { throw "Building $culture MSI failed with code $LASTEXITCODE" }
    } finally { Pop-Location }
    Test-MarkerMsi $msi $culture
}

