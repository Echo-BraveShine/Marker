from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
POWERSHELL = shutil.which('pwsh')


@unittest.skipUnless(POWERSHELL, 'PowerShell runtime fixture runs on Windows CI')
class WindowsRuntimeTests(unittest.TestCase):
    def invoke(self, families, expected):
        with tempfile.TemporaryDirectory(prefix='marker-crt-') as temporary:
            root = Path(temporary) / "VC's 中文 runtime"
            root.mkdir()
            for family, architecture, files in families:
                directory = root / family / architecture / 'Microsoft.VC145.CRT'
                directory.mkdir(parents=True)
                for name in files:
                    (directory / name).write_bytes(b'nonempty runtime fixture')
            fixture = Path(temporary) / 'verify.ps1'
            fixture.write_text('''param($Helper, $Root, $Expected)
$ErrorActionPreference = 'Stop'
. $Helper
try {
  $selected = Get-MarkerVisualCppRuntime -RedistRoot $Root
  if ($Expected -eq 'FAIL') { throw 'Expected an incomplete-runtime error' }
  if ($selected.FullName -ne (Join-Path $Root $Expected)) { throw "Wrong runtime: $($selected.FullName)" }
} catch {
  if ($Expected -ne 'FAIL' -or $_.Exception.Message -notlike 'Complete Visual C++ x64 Release CRT not found*') { throw }
}
''', encoding='utf-8')
            result = subprocess.run([POWERSHELL, '-NoProfile', '-NonInteractive', '-File', str(fixture),
                                     '-Helper', str(ROOT / '.github/release/windows-runtime.ps1'),
                                     '-Root', str(root), '-Expected', expected],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_family_and_legacy_folders_with_unrelated_and_arm64_entries(self):
        complete = ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']
        self.invoke([('v145', 'x64', complete), ('14.44.35208', 'x64', complete),
                     ('v999', 'arm64', complete), ('Preview', 'x64', ['msvcp140.dll'])],
                    str(Path('v145/x64/Microsoft.VC145.CRT')))

    def test_missing_family_runtime_falls_back_to_complete_legacy_runtime(self):
        complete = ['msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll']
        self.invoke([('v145', 'x64', ['msvcp140.dll']), ('14.44.35208', 'x64', complete)],
                    str(Path('14.44.35208/x64/Microsoft.VC145.CRT')))

    def test_incomplete_runtime_does_not_pass_validation(self):
        self.invoke([('v145', 'x64', ['msvcp140.dll'])], 'FAIL')


if __name__ == '__main__':
    unittest.main()
