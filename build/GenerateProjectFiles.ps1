$WurstBuildTemplate = [System.IO.Path]::Combine($env:BuildRoot, 'wurst.buildtemplate')
$WurstBuildOutput = [System.IO.Path]::Combine($env:ProjectRoot, 'wurst.build')

# Open the build template, expand environment vars and overwrite the wurst build file
Get-Content $WurstBuildTemplate | ForEach-Object { [System.Environment]::ExpandEnvironmentVariables($_) } | Set-Content $WurstBuildOutput

$ProjectConstantsTemplate = [System.IO.Path]::Combine($env:BuildRoot, 'ProjectConstants.wurst.template')
$ProjectConstantsOutput = [System.IO.Path]::Combine($env:WurstRoot, 'ProjectConstants.wurst')

# Open the build template, expand environment vars and overwrite the wurst build file
Get-Content $ProjectConstantsTemplate | ForEach-Object { [System.Environment]::ExpandEnvironmentVariables($_) } | Set-Content $ProjectConstantsOutput