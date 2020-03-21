.\SetupBuildEnvironment.ps1

$ExeFilePath = [System.IO.Path]::Combine($env:ToolsRoot, "W3xPipeline.exe")
$MapDirPath = [System.IO.Path]::Combine($env:SourceMapsRoot, $env:SourceMapFileName)
$OutputWurstSourceMapFilePath = $env:WurstSourceMapFilePath
$IntermediateDirPath = [System.IO.Path]::Combine($env:TempRoot, "maps")

& $ExeFilePath "$MapDirPath" "$OutputWurstSourceMapFilePath" "$IntermediateDirPath"

if ($LASTEXITCODE -eq 0)
{
  Write-Host "Pipeline finished successfully"
}
else
{
  Write-Host "Pipeline failed with exit code $LASTEXITCODE"
}