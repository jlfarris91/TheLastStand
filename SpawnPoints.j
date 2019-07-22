library SpawnPoints initializer Init requires Common, WeightedSetT, VectorT, GameConstants

  struct SpawnPoint
    public real x
    public real y
    public string name
    public boolean isEnabled
    public boolean isAlwaysValidForUndeadSpawn
    public boolean isAlwaysValidForSurvivorSpawn
  endstruct

  function interface SpawnPointFilter takes SpawnPoint sp returns boolean
  function interface SpawnPointFunc takes SpawnPoint sp returns nothing

  //! runtextmacro DEFINE_STRUCT_WEIGHTEDSET("", "WeightedSpawnPointSet", "SpawnPoint")
  //! runtextmacro DEFINE_STRUCT_VECTOR("", "SpawnPointList", "SpawnPoint")

  globals
    private constant integer SPAWN_POINT_UNIT_TYPE_ID = 'h00I'
    private SpawnPointList g_AllSpawnPoints
  endglobals

  function RegisterSpawnPoint takes string name, real x, real y returns SpawnPoint
    local SpawnPoint sp = SpawnPoint.create()
    set sp.name = name
    set sp.x = x
    set sp.y = y
    set sp.isEnabled = true
    set sp.isAlwaysValidForUndeadSpawn = false
    call g_AllSpawnPoints.push(sp)
    return sp
  endfunction

  function RegisterSpawnPointUnit takes unit spawnPointUnit returns SpawnPoint
    local SpawnPoint sp = 0
    if ( GetUnitTypeId(spawnPointUnit) != SPAWN_POINT_UNIT_TYPE_ID ) then
      call Debug.LogError("[RegisterSpawnPoint] Attempted to register a spawn point that is not the correct type")
    else
      set sp = RegisterSpawnPoint(GetUnitName(spawnPointUnit), GetUnitX(spawnPointUnit), GetUnitY(spawnPointUnit))

      // Special case for cave spawn point
      if ( spawnPointUnit == udg_zombies_CaveSpawnPoint ) then
        set sp.isAlwaysValidForUndeadSpawn = true
        set sp.isAlwaysValidForSurvivorSpawn = true
      endif

    endif
    set spawnPointUnit = null
    return sp
  endfunction

  function ForEachSpawnPointInList takes SpawnPointList spawnPointList, SpawnPointFunc func returns nothing
    local integer i = 0
    loop
      exitwhen i == spawnPointList.size()
      call func.evaluate(spawnPointList[i])
      set i = i + 1
    endloop
  endfunction

  function ForEachSpawnPoint takes SpawnPointFunc func returns nothing
    call ForEachSpawnPointInList(g_AllSpawnPoints, func)
  endfunction

  function ForEachSpawnPointInListInRange takes SpawnPointList spawnPointList, SpawnPointFunc func, real x, real y, real range returns nothing
    local SpawnPoint sp
    local real dd
    local real rr = range * range
    local integer i = 0

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      set dd = GetDistanceSqr(x, y, sp.x, sp.y)
      if ( dd < rr ) then
        call func.evaluate(sp)
      endif

      set i = i + 1
    endloop
  endfunction

  function ForEachSpawnPointInRange takes SpawnPointFunc func, real x, real y, real range returns nothing
    call ForEachSpawnPointInListInRange(g_AllSpawnPoints, func, x, y, range)
  endfunction

  function GetRandomSpawnPointFromList takes SpawnPointList spawnPointList returns SpawnPoint
    local WeightedSpawnPointSet tempSet = WeightedSpawnPointSet.create()
    local SpawnPoint sp = 0
    local integer i = 0

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      if (sp.isEnabled) then
        call tempSet.Add(sp, 1.0)
      endif

      set i = i + 1
    endloop

    set sp = 0

    if ( not tempSet.IsEmpty ) then
      set sp = tempSet.GetRandom()
    endif

    call tempSet.destroy()
    return sp
  endfunction

  function GetRandomSpawnPointFromListInRange takes SpawnPointList spawnPointList, real x, real y, real range returns SpawnPoint
    local WeightedSpawnPointSet tempSet = WeightedSpawnPointSet.create()
    local SpawnPoint sp = 0
    local real rr = range * range
    local real dd = 0.0
    local integer i = 0

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      if (sp.isEnabled) then
        set dd = GetDistanceSqr(x, y, sp.x, sp.y)
        if ( dd < rr ) then
          call tempSet.Add(sp, 1.0)
        endif
      endif

      set i = i + 1
    endloop

    set sp = 0

    if ( not tempSet.IsEmpty ) then
      set sp = tempSet.GetRandom()
    endif

    call tempSet.destroy()
    return sp
  endfunction

  function GetRandomSpawnPointInRange takes real x, real y, real range returns SpawnPoint
    return GetRandomSpawnPointFromListInRange(g_AllSpawnPoints, x, y, range)
  endfunction

  function GetNRandomSpawnPointsFromListInRange takes SpawnPointList spawnPointList, real x, real y, real range, integer count returns SpawnPointList
    local WeightedSpawnPointSet tempSet = WeightedSpawnPointSet.create()
    local SpawnPointList resultList = SpawnPointList.create()
    local SpawnPoint sp = 0
    local real rr = range * range
    local real dd = 0.0
    local integer i = 0

    loop
      exitwhen i == spawnPointList.size()
      set sp = spawnPointList[i]

      if (sp.isEnabled) then
        set dd = GetDistanceSqr(x, y, sp.x, sp.y)
        if ( dd < rr ) then
          call tempSet.Add(sp, 1.0)
        endif
      endif

      set i = i + 1
    endloop

    set i = 0

    loop
      exitwhen i == count or tempSet.IsEmpty
      set sp = tempSet.GetRandom()
      call tempSet.Remove(sp)
      call resultList.push(sp)
      set i = i + 1
    endloop

    call tempSet.destroy()

    return resultList
  endfunction

  function GetNRandomSpawnPointsInRange takes real x, real y, real range, integer count returns SpawnPointList
    return GetNRandomSpawnPointsFromListInRange(g_AllSpawnPoints, x, y, range, count)
  endfunction

  private function RegisterEnumSpawnPoint takes nothing returns nothing
    local unit u = GetEnumUnit()
    call RegisterSpawnPointUnit(u)
    call RemoveUnit(u)
    set u = null
  endfunction

  private function RegisterAllSpawnPoints takes nothing returns nothing
    local group ug = GetUnitsOfTypeIdAll(SPAWN_POINT_UNIT_TYPE_ID)
    call ForGroup(ug, function RegisterEnumSpawnPoint)
    call DestroyGroup(ug)
    set ug = null
  endfunction

  private function Init takes nothing returns nothing    
    set g_AllSpawnPoints = SpawnPointList.create()
    call RegisterAllSpawnPoints()
  endfunction

endlibrary