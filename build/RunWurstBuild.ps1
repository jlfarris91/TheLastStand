.\SetupBuildEnvironment.ps1

Push-Location $env:ProjectRoot
grill build $env:WurstSourceMapFilePath
Pop-Location