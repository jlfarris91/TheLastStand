.\SetupBuildEnvironment.ps1

# The build machines don't have this data
if ($env:IsLocalBuild -eq 0)
{
  Write-Host "Can only run LocalBuildCachedArchive.ps1 locally"
  return 1
}

$ExeFilePath = [System.IO.Path]::Combine($env:ToolsRoot, "CreateSlimArchive\CreateSlimArchive.exe")

$SourceArchiveDir = "D:\Projects\WarcraftIII\MPQ\Dump\war3.w3mod"
$DestinationArchiveDir = [System.IO.Path]::Combine($env:BuildRoot, "war3.wmod")
$ListFilePath = [System.IO.Path]::Combine($env:BuildRoot, "listfile")

if (-not (Test-Path $SourceArchiveDir))
{
  Write-Host ("Cannot find source archive dir: {0}" -f $SourceArchiveDir)
  return 1
}

if (-not (Test-Path $ListFilePath))
{
  Write-Host ("Cannot find list file: {0}" -f $ListFilePath)
  return 1
}

& $ExeFilePath "$SourceArchiveDir" "$DestinationArchiveDir" "$ListFilePath"

if ($LASTEXITCODE -eq 0)
{
  Write-Host "Created slim archive successfully"
}
else
{
  Write-Host "Failed to create slim archive with exit code $LASTEXITCODE"
}