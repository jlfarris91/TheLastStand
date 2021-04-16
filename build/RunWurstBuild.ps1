.\SetupBuildEnvironment.ps1

Push-Location $env:ProjectRoot
grill build $env:WurstSourceMapFilePath -runcompiletimefunctions -injectobjects -inline -opt -localOptimizations
Pop-Location