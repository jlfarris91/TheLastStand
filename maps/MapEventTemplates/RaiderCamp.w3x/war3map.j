//===========================================================================
// 
// Map Event Template
// 
//   Warcraft III map script
//   Generated by the Warcraft III World Editor
//   Map Author: Unknown
// 
//===========================================================================

//***************************************************************************
//*
//*  Global Variables
//*
//***************************************************************************

globals
endglobals

function InitGlobals takes nothing returns nothing
endfunction

//***************************************************************************
//*
//*  Custom Script Code
//*
//***************************************************************************

//***************************************************************************
//*
//*  Unit Creation
//*
//***************************************************************************

//===========================================================================
function CreateBuildingsForPlayer0 takes nothing returns nothing
    local player p = Player(0)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u = BlzCreateUnitWithSkin( p, 'h010', 256.0, -384.0, 270.000, 'h010' )
    set u = BlzCreateUnitWithSkin( p, 'h010', -256.0, -384.0, 270.000, 'h010' )
    set u = BlzCreateUnitWithSkin( p, 'hhou', -320.0, 192.0, 270.000, 'hhou' )
    set u = BlzCreateUnitWithSkin( p, 'hhou', -320.0, 320.0, 270.000, 'hhou' )
    set u = BlzCreateUnitWithSkin( p, 'hhou', -192.0, 320.0, 270.000, 'hhou' )
    set u = BlzCreateUnitWithSkin( p, 'h00W', -96.0, -416.0, 270.000, 'h00W' )
    set u = BlzCreateUnitWithSkin( p, 'h00W', 96.0, -416.0, 270.000, 'h00W' )
    set u = BlzCreateUnitWithSkin( p, 'h00Y', -416.0, -288.0, 270.000, 'h00Y' )
    set u = BlzCreateUnitWithSkin( p, 'h00Z', 416.0, -288.0, 270.000, 'h00Z' )
    set u = BlzCreateUnitWithSkin( p, 'h010', -512.0, -128.0, 270.000, 'h010' )
    set u = BlzCreateUnitWithSkin( p, 'h010', 512.0, -128.0, 270.000, 'h010' )
    set u = BlzCreateUnitWithSkin( p, 'h00X', -544.0, 32.0, 270.000, 'h00X' )
    set u = BlzCreateUnitWithSkin( p, 'h00X', 544.0, 32.0, 270.000, 'h00X' )
    set u = BlzCreateUnitWithSkin( p, 'h00X', 544.0, 224.0, 270.000, 'h00X' )
    set u = BlzCreateUnitWithSkin( p, 'h00X', -544.0, 224.0, 270.000, 'h00X' )
    set u = BlzCreateUnitWithSkin( p, 'h011', -448.0, -576.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', -320.0, -576.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', -320.0, -704.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', -576.0, -320.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', 576.0, -320.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', 320.0, -704.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', 320.0, -576.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', 448.0, -576.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', -576.0, -448.0, 270.000, 'h011' )
    set u = BlzCreateUnitWithSkin( p, 'h011', 576.0, -448.0, 270.000, 'h011' )
endfunction

//===========================================================================
function CreateUnitsForPlayer0 takes nothing returns nothing
    local player p = Player(0)
    local unit u
    local integer unitID
    local trigger t
    local real life

    set u = BlzCreateUnitWithSkin( p, 'h00P', -128.1, -127.0, 43.639, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00T', 151.8, 473.8, 269.134, 'h00T' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', -0.5, -205.0, 89.850, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', 130.7, -127.0, 136.937, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', 189.5, 1.6, 181.941, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', 127.9, 125.7, 225.588, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', 0.8, 192.7, 269.776, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', -129.5, 130.3, -46.212, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00P', -199.2, -1.1, -1.064, 'h00P' )
    set u = BlzCreateUnitWithSkin( p, 'h00T', 323.7, 319.6, 246.829, 'h00T' )
    set u = BlzCreateUnitWithSkin( p, 'h00T', -383.9, 4.1, -48.594, 'h00T' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 0.2, -893.7, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -388.5, -782.8, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 382.8, -766.3, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 636.5, -512.9, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -641.1, -511.2, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -644.6, -127.1, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -640.2, 259.6, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 644.3, 249.5, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 643.9, -135.1, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -0.4, -507.9, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 379.6, -380.6, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -388.4, -391.6, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 1.6, -131.2, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -383.5, 115.8, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', 381.8, 131.9, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00S', -3.0, 381.2, 270.525, 'h00S' )
    set u = BlzCreateUnitWithSkin( p, 'h00R', 378.9, 506.6, 316.163, 'h00R' )
    set u = BlzCreateUnitWithSkin( p, 'h00R', -383.3, 507.8, 41.727, 'h00R' )
    set u = BlzCreateUnitWithSkin( p, 'h00Q', 1.1, 2.0, 269.711, 'h00Q' )
endfunction

//===========================================================================
function CreatePlayerBuildings takes nothing returns nothing
    call CreateBuildingsForPlayer0(  )
endfunction

//===========================================================================
function CreatePlayerUnits takes nothing returns nothing
    call CreateUnitsForPlayer0(  )
endfunction

//===========================================================================
function CreateAllUnits takes nothing returns nothing
    call CreatePlayerBuildings(  )
    call CreatePlayerUnits(  )
endfunction

//***************************************************************************
//*
//*  Players
//*
//***************************************************************************

function InitCustomPlayerSlots takes nothing returns nothing

    // Player 0
    call SetPlayerStartLocation( Player(0), 0 )
    call SetPlayerColor( Player(0), ConvertPlayerColor(0) )
    call SetPlayerRacePreference( Player(0), RACE_PREF_HUMAN )
    call SetPlayerRaceSelectable( Player(0), true )
    call SetPlayerController( Player(0), MAP_CONTROL_USER )

endfunction

function InitCustomTeams takes nothing returns nothing
    // Force: TRIGSTR_006
    call SetPlayerTeam( Player(0), 0 )

endfunction

//***************************************************************************
//*
//*  Main Initialization
//*
//***************************************************************************

//===========================================================================
function main takes nothing returns nothing
    call SetCameraBounds( -1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -1536.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -1280.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 1024.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 1280.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -1536.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM) )
    call SetDayNightModels( "Environment\\DNC\\DNCDalaran\\DNCDalaranTerrain\\DNCDalaranTerrain.mdl", "Environment\\DNC\\DNCDalaran\\DNCDalaranUnit\\DNCDalaranUnit.mdl" )
    call NewSoundEnvironment( "Default" )
    call SetAmbientDaySound( "DalaranRuinsDay" )
    call SetAmbientNightSound( "DalaranRuinsNight" )
    call SetMapMusic( "Music", true, 0 )
    call CreateAllUnits(  )
    call InitBlizzard(  )
    call InitGlobals(  )

endfunction

//***************************************************************************
//*
//*  Map Configuration
//*
//***************************************************************************

function config takes nothing returns nothing
    call SetMapName( "TRIGSTR_001" )
    call SetMapDescription( "TRIGSTR_003" )
    call SetPlayers( 1 )
    call SetTeams( 1 )
    call SetGamePlacement( MAP_PLACEMENT_USE_MAP_SETTINGS )

    call DefineStartLocation( 0, -1856.0, 1856.0 )

    // Player setup
    call InitCustomPlayerSlots(  )
    call SetPlayerSlotAvailable( Player(0), MAP_CONTROL_USER )
    call InitGenericPlayerSlots(  )
endfunction

