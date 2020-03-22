globals
    // Generated
rect gg_rct_BaseUnits= null
rect gg_rct_debugSurvivorSpawn= null
sound gg_snd_GyrocopterImpactHit2= null
string gg_snd_Undead1
string gg_snd_Undead2
string gg_snd_Undead3
string gg_snd_UndeadDefeat
string gg_snd_UndeadVictory
string gg_snd_UndeadX1
sound gg_snd_QuestCompleted= null
sound gg_snd_RiflemanDeath= null
sound gg_snd_ZombieDeath1= null


//JASSHelper struct globals:

endglobals


//===========================================================================
// 
// The Last Stand v1.16
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Date: Sat Mar 21 20:30:25 2020
//   Map Author: Psykolambchopz
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************


function InitGlobals takes nothing returns nothing
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************

//***************************************************************************
//*
//*  Sound Assets
//*
//***************************************************************************

function InitSounds takes nothing returns nothing
    set gg_snd_GyrocopterImpactHit2=CreateSound("Units\\Human\\Gyrocopter\\GyrocopterImpactHit2.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_GyrocopterImpactHit2, 891)
    call SetSoundChannel(gg_snd_GyrocopterImpactHit2, 5)
    call SetSoundVolume(gg_snd_GyrocopterImpactHit2, - 1)
    call SetSoundPitch(gg_snd_GyrocopterImpactHit2, 1.0)
    call SetSoundDistances(gg_snd_GyrocopterImpactHit2, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_GyrocopterImpactHit2, 3000.0)
    call SetSoundConeAngles(gg_snd_GyrocopterImpactHit2, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_GyrocopterImpactHit2, 0.0, 0.0, 0.0)
    set gg_snd_Undead1="Sound\\Music\\mp3Music\\Undead1.mp3"
    set gg_snd_Undead2="Sound\\Music\\mp3Music\\Undead2.mp3"
    set gg_snd_Undead3="Sound\\Music\\mp3Music\\Undead3.mp3"
    set gg_snd_UndeadDefeat="Sound\\Music\\mp3Music\\UndeadDefeat.mp3"
    set gg_snd_UndeadVictory="Sound\\Music\\mp3Music\\UndeadVictory.mp3"
    set gg_snd_UndeadX1="Sound\\Music\\mp3Music\\UndeadX1.mp3"
    set gg_snd_QuestCompleted=CreateSound("Sound\\Interface\\QuestCompleted.wav", false, false, false, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_QuestCompleted, 5154)
    call SetSoundChannel(gg_snd_QuestCompleted, 0)
    call SetSoundVolume(gg_snd_QuestCompleted, - 1)
    call SetSoundPitch(gg_snd_QuestCompleted, 1.0)
    set gg_snd_RiflemanDeath=CreateSound("Units\\Human\\Rifleman\\RiflemanDeath.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_RiflemanDeath, 1770)
    call SetSoundChannel(gg_snd_RiflemanDeath, 0)
    call SetSoundVolume(gg_snd_RiflemanDeath, - 1)
    call SetSoundPitch(gg_snd_RiflemanDeath, 1.0)
    call SetSoundDistances(gg_snd_RiflemanDeath, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_RiflemanDeath, 3000.0)
    call SetSoundConeAngles(gg_snd_RiflemanDeath, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_RiflemanDeath, 0.0, 0.0, 0.0)
    set gg_snd_ZombieDeath1=CreateSound("Units\\Creeps\\Zombie\\ZombieDeath1.wav", false, true, true, 10, 10, "DefaultEAXON")
    call SetSoundDuration(gg_snd_ZombieDeath1, 1417)
    call SetSoundChannel(gg_snd_ZombieDeath1, 0)
    call SetSoundVolume(gg_snd_ZombieDeath1, - 1)
    call SetSoundPitch(gg_snd_ZombieDeath1, 1.0)
    call SetSoundDistances(gg_snd_ZombieDeath1, 0.0, 10000.0)
    call SetSoundDistanceCutoff(gg_snd_ZombieDeath1, 3000.0)
    call SetSoundConeAngles(gg_snd_ZombieDeath1, 0.0, 0.0, 127)
    call SetSoundConeOrientation(gg_snd_ZombieDeath1, 0.0, 0.0, 0.0)
endfunction

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateBuildingsForPlayer9 takes nothing returns nothing
    local player p= Player(9)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h01Q', 3488.0, 6688.0, 270.000, 'h01Q')
    set u=BlzCreateUnitWithSkin(p, 'h013', 9664.0, - 10624.0, 270.000, 'h013')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 7840.0, - 4576.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01H', - 10976.0, 1248.0, 270.000, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 4000.0, 9184.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01Q', 2208.0, - 3616.0, 270.000, 'h01Q')
    set u=BlzCreateUnitWithSkin(p, 'h01L', 288.0, - 8480.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01I', 1504.0, - 3616.0, 270.000, 'h01I')
    set u=BlzCreateUnitWithSkin(p, 'h01P', 864.0, - 992.0, 270.000, 'h01P')
    set u=BlzCreateUnitWithSkin(p, 'h01P', 2784.0, - 1632.0, 270.000, 'h01P')
    set u=BlzCreateUnitWithSkin(p, 'h017', 224.0, - 2272.0, 270.000, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h01W', 864.0, - 4064.0, 270.000, 'h01W')
    set u=BlzCreateUnitWithSkin(p, 'h01I', 1696.0, - 4064.0, 270.000, 'h01I')
    set u=BlzCreateUnitWithSkin(p, 'h01X', - 224.0, - 2720.0, 270.000, 'h01X')
    set u=BlzCreateUnitWithSkin(p, 'h01J', - 224.0, - 2144.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01H', 4512.0, 5280.0, 270.000, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 10144.0, - 7456.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h017', 9056.0, - 6816.0, 270.000, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h01R', 10208.0, - 6176.0, 270.000, 'h01R')
    set u=BlzCreateUnitWithSkin(p, 'h01Q', 9632.0, - 8224.0, 270.000, 'h01Q')
    set u=BlzCreateUnitWithSkin(p, 'h01O', 8672.0, 4128.0, 270.000, 'h01O')
    set u=BlzCreateUnitWithSkin(p, 'h01R', 9184.0, 4768.0, 270.000, 'h01R')
    set u=BlzCreateUnitWithSkin(p, 'h01V', - 8384.0, - 8896.0, 270.000, 'h01V')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 3296.0, - 2720.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h017', 3296.0, - 1632.0, 270.000, 'h017')
    set u=BlzCreateUnitWithSkin(p, 'h01V', 6080.0, 2496.0, 270.000, 'h01V')
    set u=BlzCreateUnitWithSkin(p, 'h01P', - 1184.0, - 5792.0, 270.000, 'h01P')
    set u=BlzCreateUnitWithSkin(p, 'h01J', 6304.0, - 10016.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01I', 6624.0, - 11616.0, 270.000, 'h01I')
    set u=BlzCreateUnitWithSkin(p, 'h017', 7264.0, - 11616.0, 270.000, 'h017')
endfunction

//===========================================================================
function CreateUnitsForPlayer9 takes nothing returns nothing
    local player p= Player(9)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h01K', - 7134.3, - 4587.5, 36.476, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h005', 4207.9, - 7300.2, 274.990, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h007', 4333.5, - 7322.9, 242.780, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 4060.8, - 7392.2, 37.585, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 4102.5, - 7342.7, 289.784, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h001', 1312.0, - 10048.0, 270.000, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h001', - 11040.0, 1568.0, 358.412, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 392.2, 4905.9, 100.462, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 304.4, 4865.0, 327.985, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 363.2, 4828.1, 40.958, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h005', 964.3, 10976.4, 292.961, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h01S', 1216.3, 11056.7, 261.547, 'h01S')
    set u=BlzCreateUnitWithSkin(p, 'h005', - 864.3, 10698.6, 314.280, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h001', 2465.8, 9156.5, 231.360, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01S', - 4739.0, 10419.9, 220.390, 'h01S')
    set u=BlzCreateUnitWithSkin(p, 'h001', 819.7, 5768.7, 219.480, 'h001')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 9638.1, 51.5, 312.032, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 9687.3, 56.6, 302.331, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 9699.1, - 42.8, 105.364, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h007', 10882.6, - 3951.0, 62.064, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 10825.8, - 3861.3, 309.297, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 10900.5, - 3879.1, 318.339, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 7239.7, - 4588.4, 1.384, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 7179.0, - 4660.2, 279.369, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 7636.2, - 5151.6, 80.112, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 4037.7, - 8541.4, 183.740, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 4359.3, - 8499.0, 353.242, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4384.2, - 8420.1, 284.456, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h005', - 11077.2, - 4520.5, 164.530, 'h005')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 6953.8, - 10538.6, 188.574, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 8488.9, - 8826.0, 281.770, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 8129.3, - 10020.4, 216.693, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 8206.2, - 10011.0, 95.265, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', - 10922.1, - 8850.0, 274.596, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01U', - 11021.4, - 8886.4, 346.047, 'h01U')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 444.2, 7313.0, 0.615, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h007', 554.7, 7364.6, 217.140, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 419.2, 7165.9, 39.134, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', 6223.7, 2436.3, 233.100, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 5933.4, 2592.0, 265.982, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 6138.3, 2404.5, 192.717, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 3470.7, - 6610.3, 43.342, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', - 3575.7, - 6648.0, 357.495, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01T', - 3710.7, - 6427.4, 140.380, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01T', 2595.5, 9068.3, 273.610, 'h01T')
    set u=BlzCreateUnitWithSkin(p, 'h01A', 5408.3, - 10731.1, 325.744, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01K', 5448.0, - 10666.1, 222.941, 'h01K')
    set u=BlzCreateUnitWithSkin(p, 'h01U', 5549.1, - 10669.2, 222.172, 'h01U')
endfunction

//===========================================================================
function CreateNeutralPassiveBuildings takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h01J', - 10720.0, 8992.0, 270.000, 'h01J')
    set u=BlzCreateUnitWithSkin(p, 'h01H', - 10528.0, 9440.0, 270.000, 'h01H')
    set u=BlzCreateUnitWithSkin(p, 'h01M', - 7424.0, 9760.0, 270.000, 'h01M')
    set u=BlzCreateUnitWithSkin(p, 'h01L', - 3552.0, 4192.0, 270.000, 'h01L')
    set u=BlzCreateUnitWithSkin(p, 'h01N', - 10656.0, - 2432.0, 270.000, 'h01N')
endfunction

//===========================================================================
function CreateNeutralPassive takes nothing returns nothing
    local player p= Player(PLAYER_NEUTRAL_PASSIVE)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u=BlzCreateUnitWithSkin(p, 'h007', - 3771.7, 9234.7, 241.256, 'h007')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4122.2, 8974.0, 239.542, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h01A', - 4126.2, 8920.9, 18.414, 'h01A')
    set u=BlzCreateUnitWithSkin(p, 'h007', 2090.2, - 8399.4, 236.311, 'h007')
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
    call CreateBuildingsForPlayer9()
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
    call CreateUnitsForPlayer9()
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreateNeutralPassiveBuildings()
    call CreateBuildingsForPlayer9() // INLINED!!
    call CreateNeutralPassive()
    call CreateUnitsForPlayer9() // INLINED!!
endfunction

//***************************************************************************
//*
//*  Regions
//*
//***************************************************************************

function CreateRegions takes nothing returns nothing
    local weathereffect we

    set gg_rct_BaseUnits=Rect(10912.0, - 11616.0, 11296.0, - 10848.0)
    set gg_rct_debugSurvivorSpawn=Rect(- 320.0, - 7648.0, - 128.0, - 7456.0)
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation(Player(0), 0)
    call ForcePlayerStartLocation(Player(0), 0)
    call SetPlayerColor(Player(0), ConvertPlayerColor(0))
    call SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(0), false)
    call SetPlayerController(Player(0), MAP_CONTROL_USER)

    // Player 1
    call SetPlayerStartLocation(Player(1), 1)
    call ForcePlayerStartLocation(Player(1), 1)
    call SetPlayerColor(Player(1), ConvertPlayerColor(1))
    call SetPlayerRacePreference(Player(1), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(1), false)
    call SetPlayerController(Player(1), MAP_CONTROL_USER)

    // Player 2
    call SetPlayerStartLocation(Player(2), 2)
    call ForcePlayerStartLocation(Player(2), 2)
    call SetPlayerColor(Player(2), ConvertPlayerColor(2))
    call SetPlayerRacePreference(Player(2), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(2), false)
    call SetPlayerController(Player(2), MAP_CONTROL_USER)

    // Player 3
    call SetPlayerStartLocation(Player(3), 3)
    call ForcePlayerStartLocation(Player(3), 3)
    call SetPlayerColor(Player(3), ConvertPlayerColor(3))
    call SetPlayerRacePreference(Player(3), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(3), false)
    call SetPlayerController(Player(3), MAP_CONTROL_USER)

    // Player 4
    call SetPlayerStartLocation(Player(4), 4)
    call ForcePlayerStartLocation(Player(4), 4)
    call SetPlayerColor(Player(4), ConvertPlayerColor(4))
    call SetPlayerRacePreference(Player(4), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(4), false)
    call SetPlayerController(Player(4), MAP_CONTROL_USER)

    // Player 5
    call SetPlayerStartLocation(Player(5), 5)
    call ForcePlayerStartLocation(Player(5), 5)
    call SetPlayerColor(Player(5), ConvertPlayerColor(5))
    call SetPlayerRacePreference(Player(5), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(5), false)
    call SetPlayerController(Player(5), MAP_CONTROL_USER)

    // Player 6
    call SetPlayerStartLocation(Player(6), 6)
    call ForcePlayerStartLocation(Player(6), 6)
    call SetPlayerColor(Player(6), ConvertPlayerColor(6))
    call SetPlayerRacePreference(Player(6), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(6), false)
    call SetPlayerController(Player(6), MAP_CONTROL_USER)

    // Player 7
    call SetPlayerStartLocation(Player(7), 7)
    call ForcePlayerStartLocation(Player(7), 7)
    call SetPlayerColor(Player(7), ConvertPlayerColor(7))
    call SetPlayerRacePreference(Player(7), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(7), false)
    call SetPlayerController(Player(7), MAP_CONTROL_USER)

    // Player 8
    call SetPlayerStartLocation(Player(8), 8)
    call ForcePlayerStartLocation(Player(8), 8)
    call SetPlayerColor(Player(8), ConvertPlayerColor(8))
    call SetPlayerRacePreference(Player(8), RACE_PREF_UNDEAD)
    call SetPlayerRaceSelectable(Player(8), false)
    call SetPlayerController(Player(8), MAP_CONTROL_COMPUTER)

    // Player 9
    call SetPlayerStartLocation(Player(9), 9)
    call ForcePlayerStartLocation(Player(9), 9)
    call SetPlayerColor(Player(9), ConvertPlayerColor(9))
    call SetPlayerRacePreference(Player(9), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(9), false)
    call SetPlayerController(Player(9), MAP_CONTROL_COMPUTER)

    // Player 10
    call SetPlayerStartLocation(Player(10), 10)
    call ForcePlayerStartLocation(Player(10), 10)
    call SetPlayerColor(Player(10), ConvertPlayerColor(10))
    call SetPlayerRacePreference(Player(10), RACE_PREF_HUMAN)
    call SetPlayerRaceSelectable(Player(10), false)
    call SetPlayerController(Player(10), MAP_CONTROL_COMPUTER)

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_093
    call SetPlayerTeam(Player(0), 0)
    call SetPlayerState(Player(0), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(1), 0)
    call SetPlayerState(Player(1), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(2), 0)
    call SetPlayerState(Player(2), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(3), 0)
    call SetPlayerState(Player(3), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(4), 0)
    call SetPlayerState(Player(4), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(5), 0)
    call SetPlayerState(Player(5), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(6), 0)
    call SetPlayerState(Player(6), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(7), 0)
    call SetPlayerState(Player(7), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(9), 0)
    call SetPlayerState(Player(9), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(0), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(1), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(2), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(3), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(4), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(5), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(7), true)
    call SetPlayerAllianceStateAllyBJ(Player(6), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(7), Player(9), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(0), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(1), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(2), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(3), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(4), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(5), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(6), true)
    call SetPlayerAllianceStateAllyBJ(Player(9), Player(7), true)

    // Force: TRIGSTR_094
    call SetPlayerTeam(Player(8), 1)
    call SetPlayerState(Player(8), PLAYER_STATE_ALLIED_VICTORY, 1)
    call SetPlayerTeam(Player(10), 1)
    call SetPlayerState(Player(10), PLAYER_STATE_ALLIED_VICTORY, 1)

    //   Allied
    call SetPlayerAllianceStateAllyBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateAllyBJ(Player(10), Player(8), true)

    //   Shared Vision
    call SetPlayerAllianceStateVisionBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateVisionBJ(Player(10), Player(8), true)

    //   Shared Control
    call SetPlayerAllianceStateControlBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateControlBJ(Player(10), Player(8), true)

    //   Shared Advanced Control
    call SetPlayerAllianceStateFullControlBJ(Player(8), Player(10), true)
    call SetPlayerAllianceStateFullControlBJ(Player(10), Player(8), true)

endfunction

function InitAllyPriorities takes nothing returns nothing

    call SetStartLocPrioCount(0, 1)
    call SetStartLocPrio(0, 0, 1, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(1, 2)
    call SetStartLocPrio(1, 0, 0, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(1, 1, 2, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(2, 2)
    call SetStartLocPrio(2, 0, 1, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(2, 1, 3, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(3, 2)
    call SetStartLocPrio(3, 0, 2, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(3, 1, 4, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(4, 2)
    call SetStartLocPrio(4, 0, 3, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(4, 1, 5, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(5, 2)
    call SetStartLocPrio(5, 0, 4, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(5, 1, 6, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(6, 2)
    call SetStartLocPrio(6, 0, 5, MAP_LOC_PRIO_HIGH)
    call SetStartLocPrio(6, 1, 7, MAP_LOC_PRIO_HIGH)

    call SetStartLocPrioCount(7, 1)
    call SetStartLocPrio(7, 0, 6, MAP_LOC_PRIO_HIGH)
endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds(- 11520.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), - 11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 11520.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), - 11520.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 11264.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 11520.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), - 11776.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
    call SetDayNightModels("Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdl", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdl")
    call SetWaterBaseColor(0, 128, 255, 255)
    call NewSoundEnvironment("Default")
    call SetAmbientDaySound("DalaranRuinsDay")
    call SetAmbientNightSound("DalaranRuinsNight")
    call SetMapMusic("Music", true, 0)
    call InitSounds()
    call CreateRegions()
    call CreateAllUnits()
    call InitBlizzard()


    call InitGlobals()

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName("TRIGSTR_080")
    call SetMapDescription("TRIGSTR_1550")
    call SetPlayers(11)
    call SetTeams(11)
    call SetGamePlacement(MAP_PLACEMENT_TEAMS_TOGETHER)

    call DefineStartLocation(0, 11648.0, - 10816.0)
    call DefineStartLocation(1, 11648.0, - 10880.0)
    call DefineStartLocation(2, 11648.0, - 10944.0)
    call DefineStartLocation(3, 11648.0, - 11008.0)
    call DefineStartLocation(4, 11648.0, - 11072.0)
    call DefineStartLocation(5, 11648.0, - 11136.0)
    call DefineStartLocation(6, 11648.0, - 11200.0)
    call DefineStartLocation(7, 11648.0, - 11264.0)
    call DefineStartLocation(8, 11648.0, - 11328.0)
    call DefineStartLocation(9, 11648.0, - 11392.0)
    call DefineStartLocation(10, 11648.0, - 11456.0)

    // Player setup
    call InitCustomPlayerSlots()
    call InitCustomTeams()
    call InitAllyPriorities()
endfunction




//Struct method generated initializers/callers:

