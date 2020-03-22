.\SetupBuildEnvironment.ps1

# The build machines don't have the data needed to run this
if ($env:IsLocalBuild -eq 0)
{
  Write-Host "Can only run RunLocalUpdateCachedArchive.ps1 locally"
  return 1
}

# 1. Run the pipeline with IsLocalBuild=true so that we use the real war3 archive data
#    This will generate a list file of all the archive files referenced by the pipeline
.\RunPipeline.ps1

# 2. Use the list file generated from RunPipeline to build our cached archive
.\LocalBuildCachedArchive.ps1

# 3. Clean up the list file
if (Test-Path "listfile") { Remove-Item "listfile" }