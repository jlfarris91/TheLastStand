.\SetupBuildEnvironment.ps1

$env:SaveSourceRoot = [System.IO.Path]::Combine($env:ProjectRoot, "..\TheLastStand_Save\wurst\Save")
$env:SaveLinkRoot = [System.IO.Path]::Combine($env:WurstRoot, "Save")

if (-Not (Test-Path $env:SaveLinkRoot))
{
  cmd /c mklink /J /d $env:SaveLinkRoot $env:SaveSourceRoot
}