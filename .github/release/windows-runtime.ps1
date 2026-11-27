function Get-MarkerVisualCppRuntime {
  param([Parameter(Mandatory = $true)][string]$RedistRoot)
  if (!(Test-Path -LiteralPath $RedistRoot -PathType Container)) {
    throw "Visual C++ redistributable directory not found: $RedistRoot"
  }
  $required = @('msvcp140.dll', 'vcruntime140.dll', 'vcruntime140_1.dll')
  $candidates = foreach ($family in Get-ChildItem -LiteralPath $RedistRoot -Directory) {
    # VS supports both numeric folders (14.x.y) and families such as v145.
    $x64 = Join-Path $family.FullName 'x64'
    if (!(Test-Path -LiteralPath $x64 -PathType Container)) { continue }
    foreach ($directory in Get-ChildItem -LiteralPath $x64 -Directory -Filter 'Microsoft.VC*.CRT') {
      $complete = $true
      foreach ($dll in $required) {
        $file = Join-Path $directory.FullName $dll
        if (!(Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -eq 0) {
          $complete = $false
          break
        }
      }
      if (!$complete) { continue }
      # Rank the actual runtime binary version; directory names are not versions.
      $info = (Get-Item -LiteralPath (Join-Path $directory.FullName 'msvcp140.dll')).VersionInfo
      [PSCustomObject]@{
        Directory = $directory
        Version = [version]::new($info.FileMajorPart, $info.FileMinorPart, $info.FileBuildPart, $info.FilePrivatePart)
      }
    }
  }
  $selected = $candidates |
    Sort-Object -Property @{ Expression = { $_.Version }; Descending = $true }, @{ Expression = { $_.Directory.FullName }; Descending = $true } |
    Select-Object -First 1
  if (!$selected) { throw "Complete Visual C++ x64 Release CRT not found under: $RedistRoot" }
  return $selected.Directory
}
