# Run elevated inside the prepared Windows VM. No token is written to disk or
# supplied on the command line; Runner's own secret input handling masks it.
$ErrorActionPreference = 'Stop'
$runner = 'C:\MarkerRunner'
if (-not $env:MARKER_RUNNER_TOKEN) { throw 'Supply the repository registration token in MARKER_RUNNER_TOKEN' }
if (-not (Test-Path "$runner\config.cmd")) { throw 'Runner package has not been prepared' }
if (Test-Path "$runner\.runner") { throw 'Runner is already registered; refusing to replace it' }
$mode = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock'
if ($mode.AllowDevelopmentWithoutDevLicense -ne 1) {
  throw 'Flutter plugin symlinks require the existing Windows Developer Mode setting'
}
# NETWORK SERVICE has no administrator rights; only these dedicated build paths
# are writable. Existing EJson SDKs and user profile directories are not changed.
& icacls.exe $runner /inheritance:r /grant '*S-1-5-20:(OI)(CI)F' '*S-1-5-18:(OI)(CI)F' '*S-1-5-32-544:(OI)(CI)F'
if ($LASTEXITCODE -ne 0) { throw 'Runner directory ACL configuration failed' }
New-Item -ItemType Directory -Force C:\MarkerValidation\pub-cache | Out-Null
foreach ($path in 'C:\MarkerValidation\flutter-x64', 'C:\MarkerValidation\pub-cache') {
  & icacls.exe $path /grant '*S-1-5-20:(OI)(CI)M' /T /C /Q
  if ($LASTEXITCODE -ne 0) { throw "Build directory ACL configuration failed: $path" }
}
$environment = @(
  'CI=true',
  'FLUTTER_SUPPRESS_ANALYTICS=true',
  'CMAKE_BUILD_PARALLEL_LEVEL=1',
  'PUB_CACHE=C:\MarkerValidation\pub-cache',
  'INNO_SETUP_COMPILER=C:\MarkerValidation\InnoSetup6\ISCC.exe',
  'GIT_CONFIG_COUNT=1',
  'GIT_CONFIG_KEY_0=safe.directory',
  'GIT_CONFIG_VALUE_0=C:/MarkerValidation/flutter-x64',
  'PATH=C:\MarkerValidation\flutter-x64\bin;C:\MarkerValidation\python;C:\ejson-platform-qa\git\cmd;C:\Windows\system32;C:\Windows;C:\Windows\System32\WindowsPowerShell\v1.0'
)
[IO.File]::WriteAllLines("$runner\.env", $environment, [Text.UTF8Encoding]::new($false))
$env:ACTIONS_RUNNER_INPUT_TOKEN = $env:MARKER_RUNNER_TOKEN
Remove-Item Env:MARKER_RUNNER_TOKEN
try {
  Push-Location $runner
  try {
    & .\config.cmd --unattended --url https://github.com/Echo-BraveShine/Marker `
      --name marker-parallels-windows-x64 --labels marker-windows-x64 --work _work `
      --runasservice --windowslogonaccount 'NT AUTHORITY\NETWORK SERVICE'
    if ($LASTEXITCODE -ne 0) { throw 'Runner registration failed' }
    $service = (Get-Content .service -Raw).Trim()
    Start-Service $service
    Get-Service $service | Select-Object Name,Status
  } finally { Pop-Location }
} finally { Remove-Item Env:ACTIONS_RUNNER_INPUT_TOKEN -ErrorAction SilentlyContinue }
