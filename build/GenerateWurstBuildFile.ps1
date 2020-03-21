.\SetupBuildEnvironment.ps1

$WurstBuildTemplate = [System.IO.Path]::Combine($env:BuildRoot, 'wurst.buildtemplate')
$OutputFilePath = [System.IO.Path]::Combine($env:ProjectRoot, 'wurst.build')

# Open the build template, expand environment vars and overwrite the wurst build file
Get-Content $WurstBuildTemplate | ForEach-Object { [System.Environment]::ExpandEnvironmentVariables($_) } | Set-Content $OutputFilePath