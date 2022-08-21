.\SetupBuildEnvironment.ps1

$env:WurstSaveSourceRoot = [System.IO.Path]::Combine($env:SaveProjectDir, "wurst\Save")
$env:WurstSaveLinkRoot = [System.IO.Path]::Combine($env:WurstRoot, "Save")

if (-Not (Test-Path $env:WurstSaveLinkRoot))
{
  cmd /c mklink /J /d $env:WurstSaveLinkRoot $env:WurstSaveSourceRoot
}

$env:SrcSaveSourceRoot = [System.IO.Path]::Combine($env:SaveProjectDir, "src\Save")
$env:SrcSaveLinkRoot = [System.IO.Path]::Combine($env:SrcRoot, "Save")

if (-Not (Test-Path $env:SrcSaveLinkRoot))
{
  cmd /c mklink /J /d $env:SrcSaveLinkRoot $env:SrcSaveSourceRoot
}