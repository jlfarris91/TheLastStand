library Looting

  interface ILootable
    public method BeginLooting takes unit lootingUnit unit lootedUnit returns nothing
  endinterface

  struct LootableUnit extends ILootable
    private real lootMaterials
  endstruct

  struct LootableUnitRegistrar
    private LootableLibrary
  endstruct

  struct LootableLibrary

    private group lootableUnits

    static method create takes nothing returns LootableLibrary
      local thistype this = allocate()
      set this.lootableUnits = CreateGroup()
      return this
    endmethod

    private method onDestroy takes nothing returns nothing
      call DestroyGroup(this.lootableUnits)
      set this.lootableUnits = null
    endmethod

  endstruct

  globals
    private LootableLibrary lootableLibrary
  endglobals

  function RegisterLootableUnit takes integer unitTypeId returns LootableRegistrar

  endfunction

  function IsUnitLootable takes unit u returns boolean
    return false
  endfunction

  function IsUnitBeingLooted takes unit u returns boolean
    return false
  endfunction

endlibrary

