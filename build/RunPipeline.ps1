.\SetupBuildEnvironment.ps1

$ExeFilePath = [System.IO.Path]::Combine($env:ToolsRoot, "W3xPipeline\W3xPipeline.exe")
$SourceMapDirPath = [System.IO.Path]::Combine($env:SourceMapsRoot, $env:SourceMapFileName)
$OutputWurstSourceMapFilePath = $env:WurstSourceMapFilePath
$IntermediateDirPath = [System.IO.Path]::Combine($env:TempRoot, "maps")
$OutputSpawnRegionScriptFile = [System.IO.Path]::Combine($env:WurstRoot, "Spawning\SpawnRegionInit.wurst")

# This path points to a dump of the entire war3.mod file typically exported from an MPQ editor
$War3ModDumpPath = "D:\Projects\WarcraftIII\MPQ\Dump\war3.w3mod"

# When building locally (specifically on Jame's machine, for now) we can reference the
# dumped casc data directly
if (($env:IsLocalBuild -eq 1) -and (Test-Path $War3ModDumpPath))
{
  $War3ArchiveDirPath = $War3ModDumpPath
  $OutputListFilePath = [System.IO.Path]::Combine($env:BuildRoot, "listfile")
}
# On the build machine we want to use only the slimmest data we can to improve build times
# and save on space so we need to use our cached, checked-in version of the casc data
# This data is cached via BuildSlimArchive.ps1 and should be updated with each War3 patch release
else
{
  $War3ArchiveDirPath = [System.IO.Path]::Combine($env:BuildRoot, "war3.wmod")
}

& $ExeFilePath --sourceMapDir "$SourceMapDirPath" --outputMapFile "$OutputWurstSourceMapFilePath" --intermediateDir "$IntermediateDirPath" --outputSpawnRegionScriptFile "$OutputSpawnRegionScriptFile" --w3modBasePath "$War3ArchiveDirPath" --outputListFilePath "$OutputListFilePath" #--mergeWar3MapSkinFiles --writeRegionsToArchive

if ($LASTEXITCODE -eq 0)
{
  Write-Host "Pipeline finished successfully"
}
else
{
  Write-Host "Pipeline failed with exit code $LASTEXITCODE"
}