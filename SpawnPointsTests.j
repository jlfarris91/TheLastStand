library SpawnPointsTests initializer Init requires SpawnPoints

  globals
    private constant integer UNDEAD_PLAYER_INDEX = 0
    private constant integer RAIDER_PLAYER_INDEX = 1
    private constant real TEST_RADIUS = 512.0
    private constant real SPAWN_POINT_UPDATE_INTERVAL = 0.1
    private SpawnPointList g_SafeSpawnPoints
    private SpawnPointList g_UnsafeSpawnPoints
  endglobals

  private function Test takes nothing returns nothing

  endfunction

  private function IsUnitUnsafe takes unit u returns boolean
    local player p = GetOwningPlayer(u)
    local player undeadPlayer = Player(UNDEAD_PLAYER_INDEX)
    local player raiderPlayer = Player(RAIDER_PLAYER_INDEX)
    local boolean isUnsafe = p == undeadPlayer or p == raiderPlayer
    set u = null
    set p = null
    set undeadPlayer = null
    set raiderPlayer = null
    return isUnsafe
  endfunction

  private function IsSpawnPointSafe takes SpawnPoint sp returns boolean
    local group ug = CreateGroup()
    local boolean isSafe = true
    local unit u

    call GroupEnumUnitsInRange(ug, sp.x, sp.y, TEST_RADIUS, null)

    loop
      set u = FirstOfGroup(ug)
      exitwhen u == null

      if ( IsUnitUnsafe(u) ) then
        set isSafe = false
        exitwhen true
      endif

      call GroupRemoveUnit(ug, u)
    endloop

    call DestroyGroup(ug)
    set ug = null

    set u = null

    return isSafe
  endfunction

  private function UpdateSpawnPoint takes SpawnPoint sp returns nothing
    if ( IsSpawnPointSafe(sp) ) then
      call g_SafeSpawnPoints.push(sp)
    else
      call g_UnsafeSpawnPoints.push(sp)
    endif
  endfunction

  private function UpdateSpawnPoints takes nothing returns nothing
    call g_SafeSpawnPoints.clear()
    call g_UnsafeSpawnPoints.clear()
    call ForEachSpawnPoint(UpdateSpawnPoint)
    call BJDebugMsg("safe: " + I2S(g_SafeSpawnPoints.size()) + " unsafe: " + I2S(g_UnsafeSpawnPoints.size()))
  endfunction

  private function StartUpdateSpawnPointsTimer takes nothing returns nothing
    local timer t = CreateTimer()
    call TimerStart(t, SPAWN_POINT_UPDATE_INTERVAL, true, function UpdateSpawnPoints)
    set t = null
  endfunction

  private function Init takes nothing returns nothing
    set g_SafeSpawnPoints = SpawnPointList.create()
    set g_UnsafeSpawnPoints = SpawnPointList.create()
    call UpdateSpawnPoints()
    call StartUpdateSpawnPointsTimer()
  endfunction
endlibrary