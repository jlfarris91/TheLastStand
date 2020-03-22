$env:Version_Major = 0
$env:Version_Minor = 1
$env:Version_Patch = "DEV"

# If built using circleci
$buildNum = [System.Environment]::GetEnvironmentVariable("CIRCLE_BUILD_NUM")
if ($buildNum -ne $null) { $env:Version_Patch = $buildNum }