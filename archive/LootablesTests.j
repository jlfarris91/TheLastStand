library LootablesTests initializer Init requires Lootables



  private function Init takes nothing returns nothing

    set lootableLibrary = LootableLibrary.create()
    call RegisterLootableUnit()
    
  endfunction

endlibrary