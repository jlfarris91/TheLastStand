library Players initializer Init requires Common, GameConstants, SafeSpawnPoints

  globals
    //private constant key KEY_PLAYER_KILLS
    private integer KEY_PLAYER_KILLS = StringHash("Kills")
    private integer KEY_PLAYER_SURVIVOR_COUNT = StringHash("SurvivorCount")
    private integer KEY_PLAYER_BASE_POINTS = StringHash("BasePoints")

    private trigger g_IncrementKillCountTrigger
  endglobals

  function GetPlayerCampFlag takes player p returns unit
    return udg_camp_CampCenter[GetConvertedPlayerId(p)]
  endfunction

  function SetPlayerCampFlag takes player p, unit u returns nothing
    set udg_camp_CampCenter[GetConvertedPlayerId(p)] = u
    set u = null
  endfunction

  function IsPlayerDeceased takes player p returns boolean
    return udg_players_IsDeceased[GetConvertedPlayerId(p)]
  endfunction

  function GivePlayerMaterials takes player p, integer mats returns nothing
    call AdjustPlayerStateBJ(mats, p, PLAYER_STATE_RESOURCE_GOLD)
  endfunction

  function GetPlayerMaterials takes player p returns integer
    return GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
  endfunction

  function SetPlayerMaterials takes player p, integer mats returns nothing
    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, mats)
  endfunction

  private function IncrementPlayerKillCount takes player p returns nothing
    local integer kills = LoadInteger(udg_players_DataTable, GetHandleId(p), KEY_PLAYER_KILLS)
    set kills = kills + 1
    call SaveInteger(udg_players_DataTable, GetHandleId(p), KEY_PLAYER_KILLS, kills)
  endfunction

  private function OnUnitDeath takes nothing returns nothing
    local unit dyingUnit = GetDyingUnit()
    local unit killingUnit = GetKillingUnit()

    if ( IsUnitEnemy(dyingUnit, GetOwningPlayer(killingUnit)) ) then
      call IncrementPlayerKillCount(GetOwningPlayer(killingUnit))
    endif

    set dyingUnit = null
    set killingUnit = null
  endfunction

  function SpawnHeroForPlayer takes player p returns nothing
    local integer playerId = GetConvertedPlayerId(p)
    local SpawnPoint sp
    local unit hero
    local location l

    if ( udg_survivorUnit[playerId] != null ) then
      call RemoveUnit(udg_survivorUnit[playerId])
      set udg_survivorUnit[playerId] = null
    endif

    set sp = GetRandomSurvivorSpawnPoint()

    if ( sp == null ) then
      call Debug.LogError("[SpawnHeroForPlayer] Could not find a safe spawn point")
      return
    endif

    set hero = CreateUnit(p, ID_HERO, sp.x, sp.y, GetRandomDirectionDeg())
    set udg_survivorUnit[playerId] = hero

    // Create the backpack effect
    call AddSpecialEffectTargetUnitBJ("chest", hero, "war3mapImported\\BackPack2.mdx")

    // TEMP: prevent hero xp gain
    call SuspendHeroXPBJ(false, hero)
    call SetPlayerHandicapXPBJ(p, 0.00)

    // Reset player's camera
    set udg_player_A = p              // TEMP
    set udg_key_A = GetHandleId(p)  // TEMP
    call ConditionalTriggerExecute(gg_trg_ResetCameraForPlayer)
    if (GetLocalPlayer() == p) then
      set l = GetUnitLoc(hero)
      call PanCameraToTimedLocForPlayer(p, l, 0.00)
      call RemoveLocation(l)
      set l = null
    endif

    call SaveUnitHandle(udg_players_DataTable, GetHandleId(p), StringHashBJ("BaseCenter"), hero)
    call SetPlayerCampFlag(p, hero)

    call SelectUnitForPlayerSingle(hero, p)

    call UnitAddItemByIdSwapped('I008', hero)
    call UnitAddItemByIdSwapped('I004', hero)
    call UnitAddItemByIdSwapped('I004', hero)
    call UnitAddItemByIdSwapped('I004', hero)
    call UnitAddItemByIdSwapped('I004', hero)
    call UnitAddItemByIdSwapped('I00C', hero)
    call UnitAddItemByIdSwapped('I005', hero)
    call UnitAddItemByIdSwapped('I003', hero)
    call UnitAddItemByIdSwapped('I003', hero)
    call UnitAddItemByIdSwapped('I003', hero)

    set udg_player_A = p              // TEMP
    set udg_key_A = GetHandleId(p)  // TEMP
    call TriggerExecute( gg_trg_ResetPlayerScores )
    call TriggerExecute( gg_trg_ResetTrackablesForPlayer )
    call TriggerExecute( gg_trg_EnableTrackingForPlayer )
    call ConditionalTriggerExecute( gg_trg_ShowPlayerStatsBoardForPlayer )

    set hero = null
  endfunction

  private function SpawnHeroForEnumPlayer takes nothing returns nothing
    call SpawnHeroForPlayer(GetEnumPlayer())
  endfunction

  function SpawnHeroesForPlayers takes nothing returns nothing
    // Make sure we spawn the hero at a safe location
    call SafeSpawnPoints_UpdateSpawnPoints()
    call ForForce(udg_players_PlayingHumans, function SpawnHeroForEnumPlayer)
  endfunction

  private function Init takes nothing returns nothing

    set g_IncrementKillCountTrigger = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(g_IncrementKillCountTrigger, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(g_IncrementKillCountTrigger, function OnUnitDeath)

  endfunction

endlibrary