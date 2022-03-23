$env:Build = "Debug"
.\SetupBuildEnvironment.ps1
.\CreateMapJunctions.ps1

Copy-Item ".\wurst_run_debug.args" "..\wurst_run.args" -Force

# The build machines don't have the data needed to run this
if ($env:IsLocalBuild -eq 0)
{
  Write-Host "Can only run PrepareLocalBuild.ps1 locally"
  return 1
}

# 1. Run the pipeline to take our source map to a map that Wurst can process
.\RunPipeline.ps1

if ($LASTEXITCODE -ne 0)
{
  return
}

$env:DevEnvironment = "true"
$env:SaveDataPathRoot = "LastStandDev"

# 2. Generate the wurst build file
.\GenerateProjectFiles.ps1

if ($LASTEXITCODE -ne 0)
{
  return
}