library Game initializer Init requires SafeSpawnPoints, Players, Zombies

  globals
    private constant real SURVIVOR_SPAWN_RANGE = 4096.0
    private constant real SURVIVOR_ITEM_CHANCE = 75.0
    private constant real DAY_ZOMBIES_SPAWN_RANGE = 6000.0
    private constant real TIME_OF_NIGHT_ALERT = 16.0
    private trigger g_OnDayTrigger
    private trigger g_OnNightTrigger
    private trigger g_NightAlertTrigger
  endglobals

  private function SpawnItemsNearPlayer takes player p returns nothing
    local unit campFlag = GetPlayerCampFlag(p)
    local integer i = 0
    local real x
    local real y
    local real r
    local real l

    if ( IsPlayerDeceased(p) ) then
      return
    endif

    loop
      exitwhen i == udg_items_DaySpawnCountPerPlayer

      set r = GetRandomReal(0.0, 2.0 * PI)
      set l = GetRandomReal(udg_items_DaySpawnMinRadius, udg_items_DaySpawnMaxRadius)
      set x = GetUnitX(campFlag) + Cos(r) * l
      set y = GetUnitY(campFlag) + Sin(r) * l

      call MainItemTypeLibrary_CreateRandomItem(60.0, 25.0, 15.0, 5.0, x, y)

      set i = i + 1
    endloop

    set campFlag = null
    set p = null

  endfunction

  private function SpawnItemsNearEnumPlayer takes nothing returns nothing
    call SpawnItemsNearPlayer(GetEnumPlayer())
  endfunction

  private function SpawnItemsNearPlayers takes nothing returns nothing
    call ForForce(udg_players_PlayingHumans, function SpawnItemsNearEnumPlayer)
  endfunction

  private function SpawnSurvivorsNearPlayer takes player p returns nothing
    local unit campFlag = GetPlayerCampFlag(p)
    local SpawnPointList spawnPointList
    local SpawnPoint sp
    local integer i = 0

    if ( IsPlayerDeceased(p) ) then
      return
    endif

    set spawnPointList = GetNRandomSurvivorSpawnPointsInRange(GetUnitX(campFlag), GetUnitY(campFlag), SURVIVOR_SPAWN_RANGE, udg_survivors_SpawnCountPerPlayer)

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      call CreateUnit(g_VillagersPlayer, ID_UNRESCUED_SURVIVOR, sp.x, sp.y, GetRandomDirectionDeg())

      // Chance to give survivor an item
      if ( GetRandomReal(0, 100.0) > SURVIVOR_ITEM_CHANCE ) then
        call MainItemTypeLibrary_CreateRandomItem( 60.0, 25.0, 15.0, 5.0, sp.x, sp.y)
        call UnitAddItemSwapped( GetLastCreatedItem(), GetLastCreatedUnit() )
      endif

      set i = i + 1
    endloop

    call spawnPointList.destroy()

    set campFlag = null
    set p = null
  endfunction

  private function SpawnSurvivorsNearEnumPlayer takes nothing returns nothing
    call SpawnSurvivorsNearPlayer(GetEnumPlayer())
  endfunction

  private function SpawnSurvivorsNearPlayers takes nothing returns nothing
    call ForForce(udg_players_PlayingHumans, function SpawnSurvivorsNearEnumPlayer)
  endfunction

  private function SpawnWanderingZombiesNearPlayer takes player p returns nothing
    local unit campFlag = GetPlayerCampFlag(p)
    local SpawnPointList spawnPointList
    local SpawnPoint sp
    local integer i = 0
    local integer zombieCount
    local integer j = 0
    local real chanceForItem

    if ( IsPlayerDeceased(p) ) then
      return
    endif

    set spawnPointList = GetNRandomUndeadSpawnPointsInRange(GetUnitX(campFlag), GetUnitY(campFlag), DAY_ZOMBIES_SPAWN_RANGE, udg_zombies_DaySpawnCountPerPlayer)

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      set zombieCount = GetRandomInt(1, 5)
      set j = 0

      loop
        exitwhen j == zombieCount
        call CreateUnit(g_UndeadPlayer, ID_WANDERING_ZOMBIE, sp.x, sp.y, GetRandomDirectionDeg())
        set j = j + 1
      endloop

      // A chance to give one zombie in the group an item
      set chanceForItem = 10.0 + I2R(zombieCount) * 10.0
      if ( GetRandomReal(0.0, 100.0) > chanceForItem ) then
        call MainItemTypeLibrary_CreateRandomItem( 60.0, 25.0, 15.0, 5.0, sp.x, sp.y)
        call UnitAddItemSwapped( GetLastCreatedItem(), GetLastCreatedUnit() )
      endif

      set i = i + 1
    endloop

    call spawnPointList.destroy()

    set campFlag = null
    set p = null
  endfunction

  private function SpawnWanderingZombiesNearEnumPlayer takes nothing returns nothing
    call SpawnWanderingZombiesNearPlayer(GetEnumPlayer())
  endfunction

  private function SpawnWanderingZombiesNearPlayers takes nothing returns nothing
    call ForForce(udg_players_PlayingHumans, function SpawnWanderingZombiesNearEnumPlayer)
  endfunction

  private function RemoveUnrescuedSurvivors takes nothing returns nothing
    local group ug = CreateGroup()
    local unit u

    call GroupEnumUnitsOfPlayer(ug, g_VillagersPlayer, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null

      if ( GetUnitTypeId(u) == ID_UNRESCUED_SURVIVOR ) then
        call RemoveUnit(u)
      endif

      call GroupRemoveUnit(ug, u)
    endloop

    call DestroyGroup(ug)
    set ug = null
    set u = null
  endfunction

  private function KillAllUndead takes nothing returns nothing
    local group ug = CreateGroup()
    local unit u

    call GroupEnumUnitsOfPlayer(ug, g_UndeadPlayer, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null
      call KillUnit(u)
      call GroupRemoveUnit(ug, u)
    endloop

    call DestroyGroup(ug)
    set ug = null
    set u = null
  endfunction

  private function RespawnDeadHeroForPlayer takes player p returns nothing
    local integer playerId = GetConvertedPlayerId(p)

    set udg_player_A = p
    set udg_key_A = GetHandleId(p)
    set udg_players_IsDeceased[playerId] = false

    call SpawnHeroForPlayer(p)

    set udg_integer_A = playerId
    set udg_string_A = GetPlayerName(p)
    call TriggerExecute(gg_trg_SetPlayerNameWithState)

  endfunction
  
  private function RespawnDeadHeroForEnumPlayer takes nothing returns nothing
    call RespawnDeadHeroForPlayer(GetEnumPlayer())
  endfunction

  private function RespawnDeadHeroesForPlayers takes nothing returns nothing
    call ForForce(udg_players_RespawnGroup, function RespawnDeadHeroForEnumPlayer)
  endfunction

  private function OnDayStart takes nothing returns nothing
    set udg_days = udg_days + 1

    call PlaySoundBJ( gg_snd_QuestCompleted )

    call StopSpawningZombies()
    call KillAllUndead()
    call SpawnItemsNearPlayers()
    call SpawnWanderingZombiesNearPlayers()    
    // Must call after creating zombies to update the safe/unsafe lists
    call SafeSpawnPoints_UpdateSpawnPoints()
    // Call after spawning zombies to avoid spawning a survivor in the middle of a bunch of zombies
    call RespawnDeadHeroesForPlayers()
    call SpawnSurvivorsNearPlayers()
    call ConditionalTriggerExecute( gg_trg_UpdateDaysUntilCanLoot )
    call QueuedTriggerAddBJ( gg_trg_UpdatePlayerStatsMultiboard, true )
    call TriggerExecute( gg_trg_UpdatePlayerStatsMultiboardTitle )

    if ( udg_days > 1 ) then
      set udg_nights = udg_nights + 1
    endif

    // Have to wait for some reason
    call TriggerSleepAction( 1.00 )
    call SetTimeOfDayScalePercentBJ( GAME_SPEED_DAY )

  endfunction

  private function OnNightStart takes nothing returns nothing

    set udg_zombies_SpawnsPerTick = udg_zombies_SpawnsPerTick + udg_zombies_SpawnsPerTickInc
    set udg_zombies_SpawnMaxPerPlayer = udg_zombies_SpawnMaxPerPlayer + udg_zombies_SpawnMaxPerPlayerInc
    
    call TriggerExecute( gg_trg_KillAllUndead )
    call ConditionalTriggerExecute( gg_trg_RemoveUnrescuedSurvivors )
    call ConditionalTriggerExecute( gg_trg_RemoveAllItems )
    call KillAllUndead()
    call RemoveUnrescuedSurvivors()
    call StartSpawningZombies()
    call ConditionalTriggerExecute( gg_trg_SpawnAboms )

    // Have to wait for some reason
    call TriggerSleepAction( 1.00 )
    call SetTimeOfDayScalePercentBJ( GAME_SPEED_NIGHT )

  endfunction

  private function OnNightAlert takes nothing returns nothing
    call DisplayTextToForce( GetPlayersAll(), "Night is approaching..." )
  endfunction

  private function Init takes nothing returns nothing

    set g_OnDayTrigger = CreateTrigger()
    call TriggerRegisterGameStateEventTimeOfDay(g_OnDayTrigger, EQUAL, TIME_OF_DAY)
    call TriggerAddAction(g_OnDayTrigger, function OnDayStart)

    set g_OnNightTrigger = CreateTrigger()
    call TriggerRegisterGameStateEventTimeOfDay(g_OnNightTrigger, EQUAL, TIME_OF_NIGHT)
    call TriggerAddAction(g_OnNightTrigger, function OnNightStart)

    set g_NightAlertTrigger = CreateTrigger()
    call TriggerRegisterGameStateEventTimeOfDay(g_NightAlertTrigger, EQUAL, TIME_OF_NIGHT_ALERT)
    call TriggerAddAction(g_NightAlertTrigger, function OnNightStart)

  endfunction

endlibrary