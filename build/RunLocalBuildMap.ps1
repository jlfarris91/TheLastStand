.\SetupBuildEnvironment.ps1

# The build machines don't have the data needed to run this
if ($env:IsLocalBuild -eq 0)
{
  Write-Host "Can only run RunLocalBuildMap.ps1 locally"
  return 1
}

# 1. Run the pipeline to take our source map to a map that Wurst can process
.\RunPipeline.ps1

if ($LASTEXITCODE -ne 0)
{
  return
}

# 2. Generate the wurst build file
.\GenerateWurstBuildFile.ps1

if ($LASTEXITCODE -ne 0)
{
  return
}

# 3. Now have Wurst build the map
.\RunWurstBuild.ps1

# 4. Update the cached archive
.\RunLocalUpdateCachedArchive.ps1