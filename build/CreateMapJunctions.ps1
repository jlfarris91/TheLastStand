.\SetupBuildEnvironment.ps1

$lastStandMapDir = [System.IO.Path]::Combine($env:SourceMapsRoot, "TheLastStand.w3x")

foreach ($file in (Get-ChildItem -Path $lastStandMapDir) | Where-Object { $_.LinkType -eq 'Junction'}) {
  Write-Output "Deleting existing junction $($file.FullName)"
  $file.Delete()
}

foreach ($file in (Get-ChildItem -Path $env:ImportsRoot)) {

  $mapRelativeFilePath = [System.IO.Path]::Combine($lastStandMapDir, $file.Name)

  $sourceFile = $file.FullName
  $linkFile = $mapRelativeFilePath

  if (-Not (Test-Path $mapRelativeFilePath))
  {
    if ($file.PSIsContainer)
    {
      cmd /c mklink /J /d $linkFile $sourceFile
    }
    else
    {
      cmd /c mklink /J $linkFile $sourceFile
    }
  }
}