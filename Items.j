//==============================================================================
//
// Items
//
//==============================================================================
library Items initializer Initialize requires Table, Common, Colors, WeightedSetT

  private struct ItemTypeDescription

    public integer itemTypeId
    public string name
    public string tooltip
    public string description
    public string extended
    public boolean pawnable
    public boolean droppable
    public boolean dropOnDeath

    public static method create takes integer itemTypeId returns ItemTypeDescription

      local thistype this = allocate()
      set this.itemTypeId = itemTypeId
      set this.name = ""
      set this.tooltip = ""
      set this.description = ""
      set this.extended = ""
      set this.pawnable = false
      set this.droppable = true
      set this.dropOnDeath = true
      return this

    endmethod

  endstruct

  private struct ItemSet

    private static constant integer KEY_NAME = 0
    private static constant integer KEY_TOOLTIP = 1
    private static constant integer KEY_DESCRIPTION = 2
    private static constant integer KEY_EXTENDED = 3
    private static constant integer KEY_ICONPATH = 4

    private itempool itemPool
    private string name
    private Color color
    private string itemRarityString

    public static method create takes string name, Color color returns ItemSet

      local thistype this = allocate()
      set this.itemPool = CreateItemPool()
      set this.name = name
      set this.color = color
      set this.itemRarityString = color.ColorizeStringARGB(name + " Item") + "|n|n"
      return this

    endmethod

    private method onDestroy takes nothing returns nothing

      call DestroyItemPool(this.itemPool)
      call Table(this).destroy()

    endmethod

    private method DecorateItem takes item i returns nothing

      local integer itemTypeId = GetItemTypeId(i)
      local ItemTypeDescription itemTypeDescription = Table(this)[itemTypeId]

      local string name = itemTypeDescription.name
      local string tooltip = itemTypeDescription.tooltip
      local string description = itemTypeDescription.description
      local string extended = itemTypeDescription.extended

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
      call SetItemPawnable(i, itemTypeDescription.pawnable)
      call SetItemDroppable(i, itemTypeDescription.droppable)
      call SetItemDropOnDeath(i, itemTypeDescription.dropOnDeath)

      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_RED, this.color.r )
      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_GREEN, this.color.g )
      call BlzSetItemIntegerFieldBJ( i, ITEM_IF_TINTING_COLOR_BLUE, this.color.b )

    endmethod

    public method PlaceRandomPoolItem takes real x, real y returns nothing
      local item i = PlaceRandomItem(this.itemPool, x, y)
      call DecorateItem(i)
      set i = null
    endmethod

    public method RegisterItemType takes ItemTypeDescription description, real weight returns nothing
      set Table(this)[description.itemTypeId] = description
      call ItemPoolAddItemType(this.itemPool, description.itemTypeId, weight)
    endmethod

  endstruct

  struct ItemSetRegistrar

    private ItemSet itemPool
    private ItemTypeDescription description
    private real weight

    public static method create takes ItemSet itemPool, integer itemTypeId, real weight returns ItemSetRegistrar

      local thistype registrar = allocate()
      set registrar.itemPool = itemPool
      set registrar.description = ItemTypeDescription.create(itemTypeId)
      set registrar.weight = weight
      return registrar

    endmethod

    public method Name takes string name returns ItemSetRegistrar
      set this.description.name = name
      return this
    endmethod

    public method Tooltip takes string tooltip returns ItemSetRegistrar
      set this.description.tooltip = tooltip
      return this
    endmethod

    public method Description takes string description returns ItemSetRegistrar
      set this.description.description = description
      return this
    endmethod

    public method ExtendedTooltip takes string extended returns ItemSetRegistrar
      set this.description.extended = extended
      return this
    endmethod

    public method Droppable takes boolean droppable returns ItemSetRegistrar
      set this.description.droppable = droppable
      return this
    endmethod

    public method DropOnDeath takes boolean dropOnDeath returns ItemSetRegistrar
      set this.description.dropOnDeath = dropOnDeath
      return this
    endmethod

    public method CanBeSold takes boolean canBeSold returns ItemSetRegistrar
      set this.description.pawnable = canBeSold
      return this
    endmethod

    public method Register takes nothing returns nothing
      call this.itemPool.RegisterItemType(this.description, this.weight)
      call this.destroy()
    endmethod

  endstruct

  //! runtextmacro DEFINE_STRUCT_WEIGHTEDSET("", "WeightedItemSet", "ItemSet")

  globals

    integer ITEM_RARITY_COMMON = 0
    integer ITEM_RARITY_UNCOMMON = 1
    integer ITEM_RARITY_RARE = 2
    integer ITEM_RARITY_EPIC = 3
    integer ITEM_RARITY_LEGENDARY = 4

    private WeightedItemSet weightedItemSets
    private ItemSet array itemPools[5]

  endglobals

  private function GetItemSet takes integer rarity returns ItemSet
    if ( rarity < 0 or rarity > ITEM_RARITY_LEGENDARY) then
      call Debug.LogError("[ChooseRandomItemType] Argument itemlevel is out of bounds")
    endif
    return itemPools[rarity]
  endfunction

  function RegisterItemType takes integer rarity, integer itemTypeId, real weight returns ItemSetRegistrar
    local ItemSet itemSet = GetItemSet(rarity)
    local ItemSetRegistrar registrar = ItemSetRegistrar.create(itemSet, itemTypeId, weight)
    return registrar
  endfunction

  function PlaceRandomItemOfRarity takes integer rarity, real x, real y returns nothing

    local ItemSet itemSet = GetItemSet(rarity)
    call itemSet.PlaceRandomPoolItem(x, y)

  endfunction

  function PlaceRandomSetItem takes real common, real uncommon, real rare, real epic, real legendary, real x, real y returns nothing
    
    local WeightedItemSet tempSet = WeightedItemSet.create()
    local ItemSet itemSet

    call tempSet.add(itemPools[ITEM_RARITY_COMMON], common)
    call tempSet.add(itemPools[ITEM_RARITY_UNCOMMON], uncommon)
    call tempSet.add(itemPools[ITEM_RARITY_RARE], rare)
    call tempSet.add(itemPools[ITEM_RARITY_EPIC], epic)
    call tempSet.add(itemPools[ITEM_RARITY_LEGENDARY], legendary)

    set itemSet = tempSet.GetRandomElem()

    call itemSet.PlaceRandomPoolItem(x, y)

    call tempSet.destroy()

  endfunction

  private function PlaceRandomPoolItem takes nothing returns nothing

    local rect r = GetPlayableMapRect()
    local location l = GetRandomLocInRect(r)
    local real x = GetLocationX(l)
    local real y = GetLocationY(l)
    local integer rarity = GetRandomInt(ITEM_RARITY_COMMON, ITEM_RARITY_LEGENDARY)

    call PlaceRandomItemOfRarity(rarity, x, y)

    call RemoveLocation(l)
    set l = null

    call RemoveRect(r)
    set r = null

  endfunction

  private function Initialize takes nothing returns nothing

    local ItemSetRegistrar registrar
    local timer t

    set itemPools[ITEM_RARITY_COMMON] = ItemSet.create("Common", Color.FromHex("FFC7C7C7"))
    set itemPools[ITEM_RARITY_UNCOMMON] = ItemSet.create("Uncommon", Color.FromHex("FFFFFFFF"))
    set itemPools[ITEM_RARITY_RARE] = ItemSet.create("Rare", Color.FromHex("FF4293F5"))
    set itemPools[ITEM_RARITY_EPIC] = ItemSet.create("Epic", Color.FromHex("FF7842F5"))
    set itemPools[ITEM_RARITY_LEGENDARY] = ItemSet.create("Legendary", Color.FromHex("FFF2ED5E"))

    set weightedItemSets = WeightedItemSet.create()
    call weightedItemSets.add(itemPools[ITEM_RARITY_COMMON], 50.0)
    call weightedItemSets.add(itemPools[ITEM_RARITY_UNCOMMON], 25.0)
    call weightedItemSets.add(itemPools[ITEM_RARITY_RARE], 15.0)
    call weightedItemSets.add(itemPools[ITEM_RARITY_EPIC], 7.0)
    call weightedItemSets.add(itemPools[ITEM_RARITY_LEGENDARY], 3.0)

    call RegisterItemType(ITEM_RARITY_COMMON, 'bspd', 1.0).Register()
    call RegisterItemType(ITEM_RARITY_UNCOMMON, 'bspd', 1.0).Register()
    call RegisterItemType(ITEM_RARITY_RARE, 'bspd', 1.0).Register()
    call RegisterItemType(ITEM_RARITY_EPIC, 'bspd', 1.0).Register()
    call RegisterItemType(ITEM_RARITY_LEGENDARY, 'bspd', 1.0).Register()

    // Spawn a random item from a random set
    //set t = CreateTimer()
    //call TimerStart(t, 3.00, true, function PlaceRandomPoolItem)
    //set t = null

  endfunction

endlibrary