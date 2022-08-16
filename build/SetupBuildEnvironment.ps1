# =============================================================================
#
# This script is intended to be run from the build directory
#
# =============================================================================

$VersionInfo = [PSCustomObject](GitVersion | ConvertFrom-Json)
$env:MapVersion = "v{0}" -f $VersionInfo.MajorMinorPatch

$env:DevEnvironment = "false"
if ($VersionInfo.BranchName.StartsWith("develop") -or
    $VersionInfo.BranchName.StartsWith("feature") -or
    $env:Build -eq "Debug") {
  $env:DevEnvironment = "true"
}

$env:TestEnvironment = "false"
if ($env:Build -eq "Tester") {
  $env:TestEnvironment = "true"
}

$env:ProjectRoot = Split-Path (Get-Location)

$env:SourceMapsDirName = "maps"
$env:SourceMapsRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:SourceMapsDirName)

$env:BuildDirName = "build"
$env:BuildRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:BuildDirName)

$env:ToolsDirName = "tools"
$env:ToolsRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:ToolsDirName)

$env:WurstDirName = "wurst"
$env:WurstRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:WurstDirName)

$env:SrcDirName = "src"
$env:SrcRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:SrcDirName)

$env:ImportsDirName = "imports"
$env:ImportsRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:ImportsDirName)

$env:TempDirName = "_build"
$env:TempRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:TempDirName)

$env:ArtifactDirName = "_artifacts"
$env:ArtifactRoot = [System.IO.Path]::Combine($env:ProjectRoot, $env:ArtifactDirName)

$env:SaveProjectRelativeDir = "..\TheLastStand_Save"
$env:SaveProjectDir = [System.IO.Path]::Combine($env:ProjectRoot, "..\TheLastStand_Save")

$env:IsLocalBuild = 1
if ($env:CI -eq "true") { $env:IsLocalBuild = 0 }

# Write-Host ("Is Local Build: {0}" -f $env:IsLocalBuild)

$env:MapAuthor = "Ozymandias"

if ($VersionInfo.PreReleaseTag -ne "") {
  $env:MapVersion = "{0}.{1}" -f $env:MapVersion, $VersionInfo.PreReleaseTag
}

$env:SourceMapFileName = "TheLastStand.w3x"

$env:MapName = "The Last Stand"
$env:MapNameVersioned = "{0} {1}" -f $env:MapName, $env:MapVersion

$env:MapNameNoSpaces = "TheLastStand"
$env:MapNameNoSpacesVersioned = "{0}{1}" -f $env:MapNameNoSpaces, $env:MapVersion

$env:WurstMapName = $env:MapNameNoSpacesVersioned
$env:WurstMapFileName = "{0}.w3x" -f $env:WurstMapName
$env:WurstSourceMapFilePath = [System.IO.Path]::Combine($env:ProjectRoot, $env:WurstMapFileName)
$env:WurstOutputMapFilePath = [System.IO.Path]::Combine($env:TempRoot, $env:WurstMapFileName)
$env:WurstOutputMapArtifactFilePath = [System.IO.Path]::Combine($env:ArtifactRoot, $env:WurstMapFileName)

$env:DiscordLink = "discord.gg/VzjbPkGN3r"

$env:BuildDate = (Get-Date -Format "MM/dd/yy")