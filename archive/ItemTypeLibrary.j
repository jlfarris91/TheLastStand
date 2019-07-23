//==============================================================================
//
// ItemTypeLibrary
//
//==============================================================================
library ItemTypeLibrary requires Table, Common, Colors, WeightedSetT, VectorT

  struct ItemType

    public integer id
    public string name
    public string tooltip
    public string description
    public string extended
    public boolean pawnable
    public boolean droppable
    public boolean dropOnDeath
    public integer maxStackSize

    public static method create takes integer id returns thistype
      local thistype this = allocate()
      set this.id = id
      set this.name = ""
      set this.tooltip = ""
      set this.description = ""
      set this.extended = ""
      set this.pawnable = false
      set this.droppable = true
      set this.dropOnDeath = true
      set this.maxStackSize = 1
      return this
    endmethod

  endstruct

  //! runtextmacro DEFINE_STRUCT_WEIGHTEDSET("", "WeightedItemTypeSet", "ItemType")

  struct ItemSet

    private static constant integer KEY_NAME = 0
    private static constant integer KEY_TOOLTIP = 1
    private static constant integer KEY_DESCRIPTION = 2
    private static constant integer KEY_EXTENDED = 3
    private static constant integer KEY_ICONPATH = 4

    private WeightedItemTypeSet itemSet
    private string name
    private Color color
    private string itemRarityString

    public static method create takes string name, Color color returns thistype
      local thistype this = allocate()
      set this.itemSet = WeightedItemTypeSet.create()
      set this.name = name
      set this.color = color
      set this.itemRarityString = color.ColorizeStringARGB(name + " Item") + "|n|n"
      return this
    endmethod

    private method onDestroy takes nothing returns nothing
      call this.itemSet.destroy()
    endmethod

    method operator Name takes nothing returns string
      return name
    endmethod

    private method DecorateItem takes item i, ItemType itemType returns nothing
      local string name = itemType.name
      local string tooltip = itemType.tooltip
      local string description = itemType.description
      local string extended = itemType.extended

      if ( name == "" ) then
        set name = GetItemName(i)
      endif

      if ( tooltip == "" ) then
        set tooltip = BlzGetItemTooltip(i)
      endif
      
      if ( description == "" ) then
        set description = BlzGetItemDescription(i)
      endif
      
      if ( extended == "" ) then
        set extended = BlzGetItemExtendedTooltip(i)      
      endif

      set name = this.color.ColorizeStringARGB(name)
      set description = this.itemRarityString + description
      set extended = this.itemRarityString + extended

      call BlzSetItemName(i, name)
      call BlzSetItemTooltip(i, tooltip)
      call BlzSetItemDescription(i, description)
      call BlzSetItemExtendedTooltip(i, extended)
      call SetItemPawnable(i, itemType.pawnable)
      call SetItemDroppable(i, itemType.droppable)
      call SetItemDropOnDeath(i, itemType.dropOnDeath)

      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_RED, this.color.r )
      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_GREEN, this.color.g )
      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_BLUE, this.color.b )

      set i = null
    endmethod

    public method CreateRandomItem takes real x, real y returns nothing
      local ItemType itemType = this.itemSet.GetRandom()
      local item i = CreateItem(itemType.id, x, y)
      call this.DecorateItem(i, itemType)
      set i = null
    endmethod

    public method RegisterItemType takes ItemType itemType, real weight returns nothing
      call this.itemSet.Add(itemType, weight)
    endmethod

    public method GetItemType takes integer itemId returns ItemType
      local WeightedItemTypeSetItem node = this.itemSet.first
      loop
        exitwhen node == 0
        if ( node.Data.id == itemId ) then
          return node.Data
        endif
        set node = node.Next
      endloop
      return 0
    endmethod

    public method GetRandomItemType takes nothing returns ItemType
      local ItemType itemType = this.itemSet.GetRandom()
      return itemType
    endmethod

    public method GetRandomItemTypeId takes nothing returns integer
      local ItemType itemType = this.itemSet.GetRandom()
      return itemType.id
    endmethod

    public method GetItemChance takes integer itemId returns real
      local ItemType itemType = this.GetItemType(itemId)
      return this.itemSet.GetChance(itemId)
    endmethod

  endstruct

  struct ItemTypeRegistrar
    private ItemType itemType
    private real weight

    public static method create takes integer itemId returns thistype
      local thistype this = allocate()
      set this.itemType = ItemType.create(itemId)
      return this
    endmethod

    private method onDestroy takes nothing returns nothing
      if ( this.itemType != 0 ) then
        call this.itemType.destroy()
      endif
    endmethod

    public method Register takes ItemSet itemSet returns thistype
      call itemSet.RegisterItemType(this.itemType, this.weight)
      return this
    endmethod

    public method Chance takes real chance returns thistype
      set this.weight = chance
      return this
    endmethod

    public method Name takes string name returns thistype
      set this.itemType.name = name
      return this
    endmethod

    public method Tooltip takes string tooltip returns thistype
      set this.itemType.tooltip = tooltip
      return this
    endmethod

    public method Description takes string description returns thistype
      set this.itemType.description = description
      return this
    endmethod

    public method ExtendedTooltip takes string extended returns thistype
      set this.itemType.extended = extended
      return this
    endmethod

    public method Droppable takes boolean droppable returns thistype
      set this.itemType.droppable = droppable
      return this
    endmethod

    public method DropOnDeath takes boolean dropOnDeath returns thistype
      set this.itemType.dropOnDeath = dropOnDeath
      return this
    endmethod

    public method CanBeSold takes boolean canBeSold returns thistype
      set this.itemType.pawnable = canBeSold
      return this
    endmethod

    public method Stacks takes integer maxStackSize returns thistype
      set this.itemType.maxStackSize = maxStackSize
      return this
    endmethod

  endstruct

  //! runtextmacro DEFINE_STRUCT_LIST("private", "ItemTypeRegistrarList", "ItemTypeRegistrar")

  struct ItemSetBuilder
    private ItemSet itemSet
    private ItemTypeRegistrarList registrars

    public static method create takes string name, Color color returns thistype
      local thistype this = allocate()
      set this.itemSet = ItemSet.create(name, color)
      set this.registrars = ItemTypeRegistrarList.create()
      return this
    endmethod

    private method onDestroy takes nothing returns nothing
      if ( this.itemSet != 0 ) then
        call this.itemSet.destroy()
      endif
      call this.registrars.destroy()
    endmethod

    public method AddItem takes integer itemId, real weight returns ItemTypeRegistrar
      local ItemTypeRegistrar registrar = ItemTypeRegistrar.create(itemId)
      call registrar.Chance(weight)
      call this.registrars.push(registrar)
      return registrar
    endmethod

    public method Build takes nothing returns ItemSet
      local ItemTypeRegistrarListItem node = this.registrars.first
      local ItemTypeRegistrar registrar
      local ItemSet tempItemSet

      loop
        exitwhen node == 0
        set registrar = node.data
        call registrar.Register(this.itemSet)
        call registrar.destroy()
        set node = node.next
      endloop

      call this.registrars.clear()

      set tempItemSet = this.itemSet
      set this.itemSet = 0

      return tempItemSet
    endmethod
  endstruct

  //! runtextmacro DEFINE_STRUCT_WEIGHTEDSET("public", "WeightedItemSetSet", "ItemSet")
  //! runtextmacro DEFINE_VECTOR("", "ItemSetLibraryWeightList", "real")

  globals
    integer ITEM_RARITY_COMMON = 0
    integer ITEM_RARITY_RARE = 1
    integer ITEM_RARITY_EPIC = 2
    integer ITEM_RARITY_LEGENDARY = 3
  endglobals

  struct ItemSetLibrary
    private WeightedItemSetSet itemSets

    public static method create takes nothing returns thistype
      local thistype this = allocate()
      set this.itemSets = WeightedItemSetSet.create()
      return this
    endmethod

    private method onDestroy takes nothing returns nothing
      call this.itemSets.destroy()
    endmethod

    public method Add takes ItemSet itemSet, real weight returns thistype
      call this.itemSets.Add(itemSet, weight)
      return this
    endmethod

    public method Remove takes ItemSet itemSet returns thistype
      call this.itemSets.Remove(itemSet)
      return this
    endmethod

    public method GetItemSetByName takes string name returns ItemSet
      local WeightedItemSetSetItem node = this.itemSets.first
      loop
        exitwhen node == 0
        if ( node.Data.Name == name ) then
          return node.Data
        endif
        set node = node.Next
      endloop
      call Debug.LogError("[GetItemSetByName] Could not find ItemSet with name '" + name + "'")
      return 0
    endmethod

    private method GetRandomItemSetWithWeights takes ItemSetLibraryWeightList weights returns ItemSet
      local WeightedItemSetSet tempSet = WeightedItemSetSet.create()
      local WeightedItemSetSetItem itemSetsNode
      local ItemSet itemSet
      local integer i = 0

      if ( weights.size() != this.itemSets.Count ) then
        call Debug.LogError("[GetRandomItemSet] Incorrect number of weights. Got " + I2S(weights.size()) + " but expected " + I2S(this.itemSets.Count))
      endif

      set itemSetsNode = this.itemSets.first
      set i = 0

      loop
        exitwhen i == weights.size()
        call tempSet.Add(itemSetsNode.Data, weights[i])
        set itemSetsNode = itemSetsNode.Next
        set i = i + 1
      endloop

      set itemSet = tempSet.GetRandom()    
      call tempSet.destroy()
      return itemSet
    endmethod

    public method GetRandomItemType takes nothing returns integer
      local ItemSet itemSet = this.itemSets.GetRandom()
      return itemSet.GetRandomItemTypeId()
    endmethod

    public method GetRandomItemTypeUsingWeights takes ItemSetLibraryWeightList weights returns integer
      local ItemSet itemSet = this.GetRandomItemSetWithWeights(weights)
      return itemSet.GetRandomItemTypeId()
    endmethod

    public method CreateRandomItem takes real x, real y returns nothing
      local ItemSet itemSet = this.itemSets.GetRandom()
      call itemSet.CreateRandomItem(x, y)
    endmethod

    public method CreateRandomItemWithWeights takes ItemSetLibraryWeightList weights, real x, real y returns nothing
      local ItemSet itemSet = this.GetRandomItemSetWithWeights(weights)
      call itemSet.CreateRandomItem(x, y)
    endmethod

    public method GetItemChance takes integer itemId returns real
      local WeightedItemSetSetItem itemSetNode = this.itemSets.first
      local WeightedItemTypeSetItem itemTypeNode
      local WeightedItemTypeSet itemSet
      local ItemType itemType

      loop
        exitwhen itemSetNode == 0

        set itemSet = itemSetNode.Data
        set itemTypeNode = itemSet.first

        loop
          exitwhen itemTypeNode == 0

          set itemType = itemTypeNode.Data

          if ( itemTypeNode.Data.id == itemId ) then
            // Found the item in this set
            return itemSet.GetChance(itemType)
          endif

          set itemTypeNode = itemTypeNode.Next
        endloop

        set itemSetNode = itemSetNode.Next
      endloop

      return 0.0
    endmethod

    public method GetOverallItemChance takes integer itemId returns real
      local WeightedItemSetSetItem itemSetNode = this.itemSets.first
      local WeightedItemTypeSetItem itemTypeNode
      local WeightedItemTypeSet itemSet
      local ItemType itemType

      loop
        exitwhen itemSetNode == 0

        set itemSet = itemSetNode.Data
        set itemTypeNode = itemSet.first

        loop
          exitwhen itemTypeNode == 0

          set itemType = itemTypeNode.Data

          if ( itemTypeNode.Data.id == itemId ) then
            // Found the item in this set
            return itemSet.GetChance(itemType) * this.itemSets.GetChance(itemSet)
          endif

          set itemTypeNode = itemTypeNode.Next
        endloop

        set itemSetNode = itemSetNode.Next
      endloop

      return 0.0
    endmethod
  endstruct
endlibrary