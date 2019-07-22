library Zombies initializer Init requires Common, SpawnPoints, Players, Tags

  globals
    private constant real ZOMBIES_SPAWN_RANGE = 4096.0
    private constant real ZOMBIES_SPAWN_TIMER_INTERVAL = 5.0

    private group array g_ZombiesSpawnForPlayer[8]
    private constant key KEY_SPAWNED_FOR_PLAYER
    private hashtable g_ZombiesHashtable
    private timer g_ZombieSpawnTimer
    private trigger g_OnZombieKilledTrigger
  endglobals

  private function GetClosestTargetStructure takes player p, real x, real y returns unit
    local integer playerId = GetConvertedPlayerId(p)
    local group ug = CreateGroup()
    local real distance = 999999.0
    local unit target
    local unit u
    local real d

    call GroupEnumUnitsOfPlayer(ug, p, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null

      if ( IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitInvulnerable(u) ) then
        set d = GetDistanceSqr(GetUnitX(u), GetUnitY(u), x, y)
        if ( d < distance ) then
          set target = u
          set distance = d
        endif
      endif

      call GroupRemoveUnit(ug, u)
    endloop

    call DestroyGroup(ug)
    set ug = null
    set u = null
    set p = null

    if ( target == null ) then
      call Debug.LogError("[GetClosestTargetStructure] Could not find suitable target for zombie")
    endif

    return target
  endfunction
  
  private function GetClosestTargetUnit takes player p, real x, real y returns unit
    local integer playerId = GetConvertedPlayerId(p)
    local group ug = CreateGroup()
    local real distance = 999999.0
    local unit target
    local unit u
    local real d

    call GroupEnumUnitsOfPlayer(ug, p, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null

      if ( not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitInvulnerable(u) ) then
        set d = GetDistanceSqr(GetUnitX(u), GetUnitY(u), x, y)
        if ( d < distance ) then
          set target = u
          set distance = d
        endif
      endif

      call GroupRemoveUnit(ug, u)
    endloop

    call DestroyGroup(ug)
    set ug = null
    set u = null
    set p = null

    if ( target == null ) then
      call Debug.LogError("[GetClosestTargetUnit] Could not find suitable target for zombie")
    endif

    return target
  endfunction

  private function GetClosestZombieTarget takes player p, real x, real y returns unit
    local integer playerId = GetConvertedPlayerId(p)
    if ( udg_camp_IsCompleted[playerId] == true) then
      return GetClosestTargetStructure(p, x, y)
    else
      return GetClosestTargetUnit(p, x, y)
    endif
  endfunction

  private function SpawnZombieForPlayer takes player p, real x, real y returns nothing
    local integer playerId = GetConvertedPlayerId(p)
    local unit zombie
    local unit target
    local real scale
    local real speed

    set zombie = CreateUnit(g_UndeadPlayer, ID_ZOMBIE, x, y, GetRandomDirectionDeg())

    set scale = GetRandomReal(90.00, 110.00)
    call SetUnitScalePercent(zombie, scale, scale, scale)

    call SetUnitAnimation(zombie, "birth")

    call SavePlayerHandle(g_ZombiesHashtable, GetHandleId(zombie), KEY_SPAWNED_FOR_PLAYER, p)

    call GroupAddUnitSimple(zombie, g_ZombiesSpawnForPlayer[playerId])

    set speed = BlzGetUnitRealField(zombie, UNIT_RF_SPEED) * GetRandomReal(0.9, 1.1)
    call BlzSetUnitRealField(zombie, UNIT_RF_SPEED, speed)

    set target = GetClosestZombieTarget(p, GetUnitX(zombie), GetUnitY(zombie))
    if (target != null) then
      call Debug.Log("Zombie ordered to attack " + GetUnitName(target))
      call IssueTargetOrder(zombie, "attack", target)
    else
      call BlzSetUnitRealField(zombie, UNIT_RF_ACQUISITION_RANGE, 99999.00)
    endif

    set zombie = null
    set target = null
  endfunction

  private function SpawnZombiesNearPlayer takes player p returns nothing
    local unit campFlag = GetPlayerCampFlag(p)
    local SpawnPointList spawnPointList
    local SpawnPoint sp
    local integer i = 0

    if ( IsPlayerDeceased(p) ) then
      return
    endif

    set spawnPointList = GetNRandomUndeadSpawnPointsInRange(GetUnitX(campFlag), GetUnitY(campFlag), ZOMBIES_SPAWN_RANGE, R2I(udg_zombies_SpawnsPerTick))

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      if ( CountUnitsInGroup(g_ZombiesSpawnForPlayer[GetConvertedPlayerId(p)]) < udg_zombies_SpawnMaxPerPlayer ) then
        call SpawnZombieForPlayer(p, sp.x, sp.y)
      endif
      
      set i = i + 1
    endloop

    call spawnPointList.destroy()

    set campFlag = null
    set p = null
  endfunction

  private function SpawnZombiesNearEnumPlayer takes nothing returns nothing
    call SpawnZombiesNearPlayer(GetEnumPlayer())
  endfunction

  private function SpawnZombiesNearPlayers takes nothing returns nothing
    call ForForce(udg_players_PlayingHumans, function SpawnZombiesNearEnumPlayer)
  endfunction

  function StartSpawningZombies takes nothing returns nothing
    call TimerStart(g_ZombieSpawnTimer, ZOMBIES_SPAWN_TIMER_INTERVAL, true, function SpawnZombiesNearPlayers)
  endfunction

  function StopSpawningZombies takes nothing returns nothing
    call PauseTimer(g_ZombieSpawnTimer)
  endfunction

  private function OnZombieKilled takes nothing returns nothing
    local unit zombie
    local unit killingUnit
    local player targetPlayer
    local integer targetPlayerId

    if ( GetUnitTypeId(GetDyingUnit()) != ID_ZOMBIE ) then
      return
    endif

    set zombie = GetDyingUnit()
    set killingUnit = GetKillingUnit()

    set targetPlayer = LoadPlayerHandle(g_ZombiesHashtable, GetHandleId(zombie), KEY_SPAWNED_FOR_PLAYER)
    set targetPlayerId = GetConvertedPlayerId(targetPlayer)

    call GroupRemoveUnit(g_ZombiesSpawnForPlayer[targetPlayerId], zombie)

    // Zombies have a chance to give materials to the killing player
    if ( GetOwningPlayer(killingUnit) != null ) then
      if ( GetRandomReal(0.0, 100.0) > udg_zombies_ChanceToGiveMats ) then
        call GivePlayerMaterials(GetOwningPlayer(killingUnit), 1)
        call CreateMaterialsTag(GetUnitX(zombie), GetUnitY(zombie), 1)
      endif
    endif

    set zombie = null
    set killingUnit = null
    set targetPlayer = null
  endfunction

  private function Init takes nothing returns nothing
    local integer i = 0

    call InitHashtable()
    set g_ZombiesHashtable = bj_lastCreatedHashtable

    loop
      exitwhen i == 8
      set g_ZombiesSpawnForPlayer[i] = CreateGroup()
      set i = i + 1
    endloop

    set g_ZombieSpawnTimer = CreateTimer()

    set g_OnZombieKilledTrigger = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(g_OnZombieKilledTrigger, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(g_OnZombieKilledTrigger, function OnZombieKilled)

  endfunction
endlibrary