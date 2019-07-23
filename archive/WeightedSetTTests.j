library WeightedSetTests initializer Initialize requires WeightedSetT

  private function EnumTest takes nothing returns nothing
    local WeightedIntegerSetItem i = GetEnumWeightedIntegerSetItem()
    local WeightedIntegerSet s = GetEnumWeightedIntegerSet()
    call BJDebugMsg("data: '" + Id2String(i.Data) + "' weight: " + R2S(i.Weight) + " chance: " + R2S(s.GetChance(i.Data)))

    call CreateItem(i.Data, GetRandomReal(-100.0, 100.0), GetRandomReal(-100.0, 100.0))

  endfunction

  private function Initialize takes nothing returns nothing

    local WeightedIntegerSet itemSet = WeightedIntegerSet.create()
    local integer randomItemType

    call itemSet.Add('tbar', 100.0)
    call itemSet.Add('afac', 22.0)
    call itemSet.Add('spsh', 67.0)
    call itemSet.Add('belv', 40.0)

    set randomItemType = itemSet.GetRandom()
    call BJDebugMsg("Random item type: " + I2S(randomItemType))

    set randomItemType = itemSet.GetRandom()
    call BJDebugMsg("Random item type: " + I2S(randomItemType))

    set randomItemType = itemSet.GetRandom()
    call BJDebugMsg("Random item type: " + I2S(randomItemType))

    set randomItemType = itemSet.GetRandom()
    call BJDebugMsg("Random item type: " + I2S(randomItemType))

    call itemSet.ForEach(function EnumTest)

  endfunction

endlibrary