# =============================================================================
#
# This script is inteded to be run from the build directory
#
# =============================================================================

$env:ProjectRoot = Split-Path (Get-Location)

$env:SourceMapsDirName = "maps"
$env:SourceMapsRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:SourceMapsDirName)

$env:BuildDirName = "build"
$env:BuildRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:BuildDirName)

$env:ToolsDirName = "tools"
$env:ToolsRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:ToolsDirName)

$env:WurstDirName = "wurst"
$env:WurstRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:WurstDirName)

$env:TempDirName = "_build"
$env:TempRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:TempDirName)

$env:ArtifactDirName = "_artifacts"
$env:ArtifactRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:ArtifactDirName)

.\buildtarget.ps1

$env:IsLocalBuild = 0
if ($env:Version_Patch -eq "DEV") { $env:IsLocalBuild = 1 }

Write-Host ("Is Local Build: {0}" -f $env:IsLocalBuild)
Write-Host ("Version Major: {0}" -f $env:Version_Major)
Write-Host ("Version Minor: {0}" -f $env:Version_Minor)
Write-Host ("Version Patch: {0}" -f $env:Version_Patch)

$env:MapAuthor = "Ozymandias"
$env:MapVersion = "v{0}.{1}.{2}" -f $env:Version_Major, $env:Version_Minor, $env:Version_Patch

$env:SourceMapFileName = "TheLastStand.w3x"

$env:MapName = "The Last Stand"
$env:MapNameVersioned = "{0} {1}" -f $env:MapName, $env:MapVersion

$env:MapNameNoSpaces = "TheLastStand"
$env:MapNameNoSpacesVersioned = "{0}{1}" -f $env:MapNameNoSpaces, $env:MapVersion

if ($env:IsLocalBuild -eq 1)
{
  $env:WurstMapName = $env:MapNameNoSpaces
}
else
{
  $env:WurstMapName = $env:MapNameNoSpacesVersioned
}

$env:WurstMapFileName = "{0}.w3x" -f $env:WurstMapName
$env:WurstSourceMapFilePath = [System.IO.Path]::Combine($env:ProjectRoot, $env:WurstMapFileName)
$env:WurstOutputMapFilePath = [System.IO.Path]::Combine($env:TempRoot, $env:WurstMapFileName)
$env:WurstOutputMapArtifactFilePath = [System.IO.Path]::Combine($env:ArtifactRoot, $env:WurstMapFileName)