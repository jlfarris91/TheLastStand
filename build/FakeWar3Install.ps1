.\SetupBuildEnvironment.ps1

if ($env:IsLocalBuild -eq 1)
{
  Write-Host "Do not run FakeWar3Install.ps1 locally"
  return 1
}

$GameExePath = [System.IO.Path]::Combine($env:BuildRoot, "Warcraft III.exe")

$InstallPathKeyName = "Program"
$War3RegDir = ".\Software\Blizzard Entertainment\Warcraft III\"

Push-Location
Set-Location HKCU:
if (-not (Test-Path $War3RegDir))
{
    Write-Host ("Creating reg key: {0}" -f $War3RegDir)
    New-Item -Path $War3RegDir -Force
}
Write-Host ("Setting reg key property {0} = {1}" -f $InstallPathKeyName, $GameExePath)
Set-ItemProperty -Path $War3RegDir -Name $InstallPathKeyName -Value $GameExePath
Pop-Location
