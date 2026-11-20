$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio/Installer/vswhere.exe'
$installation = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (!$installation) { throw 'Visual C++ build tools not found' }
$vcvars = Join-Path $installation 'VC/Auxiliary/Build/vcvars64.bat'
$staging = Join-Path ([IO.Path]::GetTempPath()) ('marker-drop-' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $staging | Out-Null
try {
  $source = Join-Path $root 'test/windows_drop_test.cpp'
  $binary = Join-Path $staging 'drop-test.exe'
  $object = Join-Path $staging 'drop-test.obj'
  $script = Join-Path $staging 'test.cmd'
  $lines = @(
    '@echo off',
    ('call "{0}" >nul' -f $vcvars),
    'if errorlevel 1 exit /b %errorlevel%',
    ('cl /nologo /std:c++17 /EHsc /W4 /WX /utf-8 "{0}" /Fe:"{1}" /Fo:"{2}" /link shell32.lib' -f $source, $binary, $object),
    'if errorlevel 1 exit /b %errorlevel%',
    ('"{0}"' -f $binary),
    'exit /b %errorlevel%'
  )
  [IO.File]::WriteAllLines($script, $lines, [Text.UTF8Encoding]::new($false))
  & $env:ComSpec /d /c $script
  if ($LASTEXITCODE -ne 0) { throw "Native Windows drop test failed: $LASTEXITCODE" }
} finally {
  Remove-Item -Recurse -Force $staging
}
