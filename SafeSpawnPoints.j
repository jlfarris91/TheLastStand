library SafeSpawnPoints initializer Init requires SpawnPoints, Common

  globals
    private constant real TEST_RADIUS = 1024.0
    private constant real SPAWN_POINT_UPDATE_INTERVAL = 2.0
    private SpawnPointList g_SafeSpawnPoints
    private SpawnPointList g_UnsafeSpawnPoints
    private SpawnPointList g_SurvivorSpawnPoints
    private SpawnPointList g_UndeadSpawnPoints
  endglobals

  function GetRandomSafeSpawnPoint takes nothing returns SpawnPoint
    return GetRandomSpawnPointFromList(g_SafeSpawnPoints)
  endfunction

  function GetRandomSafeSpawnPointInRange takes real x, real y, real range returns SpawnPoint
    return GetRandomSpawnPointFromListInRange(g_SafeSpawnPoints, x, y, range)
  endfunction

  function GetNRandomSafeSpawnPointsInRange takes real x, real y, real range, integer count returns SpawnPointList
    return GetNRandomSpawnPointsFromListInRange(g_SafeSpawnPoints, x, y, range, count)
  endfunction

  function GetRandomUnsafeSpawnPointInRange takes real x, real y, real range returns SpawnPoint
    return GetRandomSpawnPointFromListInRange(g_UnsafeSpawnPoints, x, y, range)
  endfunction

  function GetNRandomUnsafeSpawnPointsInRange takes real x, real y, real range, integer count returns SpawnPointList
    return GetNRandomSpawnPointsFromListInRange(g_UnsafeSpawnPoints, x, y, range, count)
  endfunction

  function GetRandomSurvivorSpawnPoint takes nothing returns SpawnPoint
    return GetRandomSpawnPointFromList(g_SurvivorSpawnPoints)
  endfunction

  function GetRandomSurvivorSpawnPointInRange takes real x, real y, real range returns SpawnPoint
    return GetRandomSpawnPointFromListInRange(g_SurvivorSpawnPoints, x, y, range)
  endfunction

  function GetNRandomSurvivorSpawnPointsInRange takes real x, real y, real range, integer count returns SpawnPointList
    return GetNRandomSpawnPointsFromListInRange(g_SurvivorSpawnPoints, x, y, range, count)
  endfunction

  function GetRandomUndeadSpawnPointInRange takes real x, real y, real range returns SpawnPoint
    return GetRandomSpawnPointFromListInRange(g_UndeadSpawnPoints, x, y, range)
  endfunction

  function GetNRandomUndeadSpawnPointsInRange takes real x, real y, real range, integer count returns SpawnPointList
    return GetNRandomSpawnPointsFromListInRange(g_UndeadSpawnPoints, x, y, range, count)
  endfunction

  private function UpdateSpawnPoint takes SpawnPoint sp returns nothing
    local group ug = CreateGroup()
    local player owningPlayer 
    local unit u = null
    local boolean isSafe = true
    local boolean isValidForSurvivor = true
    local boolean isValidForUndead = true
    local boolean isUnitLootable = false

    call GroupEnumUnitsInRange(ug, sp.x, sp.y, TEST_RADIUS, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null

      set owningPlayer = GetOwningPlayer(u)

      if ( IsUnitAliveBJ(u) ) then

        // Don't let survivors spawn near enemies or player units
        if ( IsUnitEnemy(u, g_VillagersPlayer) or IsPlayerInForce(owningPlayer, udg_players_Humans) ) then
          set isValidForSurvivor = false
        endif

        if ( IsUnitEnemy(u, g_VillagersPlayer) ) then
          set isSafe = false
        endif

        set isUnitLootable = owningPlayer == g_VillagersPlayer and IsUnitInvulnerable(u)

        if ( IsUnitEnemy(u, g_UndeadPlayer) and not isUnitLootable ) then
          set isValidForUndead = false
        endif

      endif

      call GroupRemoveUnit(ug, u)
    endloop

    if ( isSafe ) then
      call g_SafeSpawnPoints.push(sp)
    else
      call g_UnsafeSpawnPoints.push(sp)
    endif

    if ( isValidForSurvivor ) then
      call g_SurvivorSpawnPoints.push(sp)
    endif

    if ( isValidForUndead ) then
      call g_UndeadSpawnPoints.push(sp)
    endif

    call DestroyGroup(ug)
    set ug = null
    set u = null
    set owningPlayer = null
  endfunction

  public function UpdateSpawnPoints takes nothing returns nothing
    call g_SafeSpawnPoints.clear()
    call g_UnsafeSpawnPoints.clear()
    call g_SurvivorSpawnPoints.clear()
    call g_UndeadSpawnPoints.clear()

    call ForEachSpawnPoint(UpdateSpawnPoint)

    //call BJDebugMsg("safe: " + I2S(g_SafeSpawnPoints.size()) + " unsafe: " + I2S(g_UnsafeSpawnPoints.size()) + " survivor: " + I2S(g_SurvivorSpawnPoints.size()) + " undead: " + I2S(g_UndeadSpawnPoints.size()))
  endfunction

  private function StartUpdateSpawnPointsTimer takes nothing returns nothing
    local timer t = CreateTimer()
    call TimerStart(t, SPAWN_POINT_UPDATE_INTERVAL, true, function UpdateSpawnPoints)
    set t = null
  endfunction

  private function Init takes nothing returns nothing
    set g_SafeSpawnPoints = SpawnPointList.create()
    set g_UnsafeSpawnPoints = SpawnPointList.create()
    set g_SurvivorSpawnPoints = SpawnPointList.create()
    set g_UndeadSpawnPoints = SpawnPointList.create()
    call UpdateSpawnPoints()
    call StartUpdateSpawnPointsTimer()
  endfunction

endlibrary