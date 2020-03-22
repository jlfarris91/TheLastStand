.\SetupBuildEnvironment.ps1

# We need to do this because CircleCI doesn't let us specify the artifacts using environment variables
# Instead, we create a new folder for the artifacts that CircleCI config knows about and move the wurst-built map there

# Create a folder for the artifacts
if (-not (Test-Path -Path $env:ArtifactRoot))
{
  Write-Host ("Creating artifacts directory: {0}" -f $env:ArtifactRoot)
  New-Item -Path $env:ArtifactRoot -ItemType directory
}

Write-Host ("Moving wurst output map to artifacts folder {0} -> {1}" -f $env:WurstOutputMapFilePath, $env:WurstOutputMapArtifactFilePath)
Move-Item -Path $env:WurstOutputMapFilePath -Destination $env:WurstOutputMapArtifactFilePath