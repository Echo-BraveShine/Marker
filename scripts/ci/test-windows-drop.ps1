$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
if (!(Test-Path -LiteralPath $vswhere)) { throw "vswhere not found: $vswhere" }
$installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if ($LASTEXITCODE -ne 0 -or !$installation) { throw 'Visual C++ build tools not found' }
$vcvars = Join-Path $installation 'VC/Auxiliary/Build/vcvars64.bat'
if (!(Test-Path -LiteralPath $vcvars)) { throw "VC environment script not found: $vcvars" }
$logParent = if ($env:RUNNER_TEMP) { $env:RUNNER_TEMP } else { Join-Path $root 'build' }
$logs = Join-Path $logParent 'marker-windows-drop'
New-Item -ItemType Directory -Path $logs -Force | Out-Null
$phase = Join-Path $logs 'phase.txt'
$setupLog = Join-Path $logs 'setup.log'
$compileLog = Join-Path $logs 'compile.log'
$executionLog = Join-Path $logs 'execution.log'
foreach ($file in @($phase, $setupLog, $compileLog, $executionLog)) {
  [IO.File]::WriteAllText($file, '')
}
$staging = Join-Path ([IO.Path]::GetTempPath()) ('marker-drop-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $staging | Out-Null
try {
  $source = Join-Path $root 'test/windows_drop_test.cpp'
  $binary = Join-Path $staging 'drop-test.exe'
  $object = Join-Path $staging 'drop-test.obj'
  $script = Join-Path $staging 'test.cmd'
  $lines = @(
    '@echo off',
    'setlocal DisableDelayedExpansion',
    'chcp 65001 >nul',
    ('>"{0}" echo setup' -f $phase),
    ('call "{0}" >"{1}" 2>&1' -f $vcvars, $setupLog),
    'if errorlevel 1 exit /b %errorlevel%',
    ('>"{0}" echo compile' -f $phase),
    ('cl /nologo /std:c++17 /EHsc /W4 /WX /utf-8 "{0}" /Fe:"{1}" /Fo:"{2}" /link shell32.lib >"{3}" 2>&1' -f $source, $binary, $object, $compileLog),
    'if errorlevel 1 exit /b %errorlevel%',
    ('>"{0}" echo execution' -f $phase),
    ('"{0}" >"{1}" 2>&1' -f $binary, $executionLog),
    'exit /b %errorlevel%'
  )
  [IO.File]::WriteAllLines($script, $lines, [Text.UTF8Encoding]::new($false))
  & $env:ComSpec /d /c $script
  $exitCode = $LASTEXITCODE
  foreach ($file in @($setupLog, $compileLog, $executionLog)) {
    Write-Host "::group::Windows drop test: $([IO.Path]::GetFileName($file))"
    Get-Content -LiteralPath $file -Encoding utf8 | ForEach-Object { Write-Host $_ }
    Write-Host '::endgroup::'
  }
  if ($exitCode -ne 0) {
    $stage = ([string](Get-Content -LiteralPath $phase -Raw)).Trim()
    if (!$stage) { $stage = 'launcher' }
    throw "Native Windows drop test failed during $stage (exit $exitCode). Logs: $logs"
  }
} finally {
  Remove-Item -Recurse -Force $staging
}
