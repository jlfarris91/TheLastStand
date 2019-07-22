library ItemTypeLibraryTests initializer Init requires ItemTypeLibrary

  globals
    public ItemSetLibrary g_MainItemSetLibrary
  endglobals

  private function Test takes nothing returns nothing

    local integer i = 0

    loop
      exitwhen i == 10
      call g_MainItemSetLibrary.CreateRandomItem(GetRandomReal(-1000.0, 1000.0), GetRandomReal(-1000.0, 1000.0))
      set i = i + 1
    endloop

  endfunction

  private function Init takes nothing returns nothing

    local ItemSet commonSet = ItemSet.create("Common", Color.FromHex("FFC7C7C7"))
    local ItemSet rareSet = ItemSet.create("Rare", Color.FromHex("FF4293F5"))
    local ItemSet epicSet = ItemSet.create("Epic", Color.FromHex("FF7842F5"))
    local ItemSet legendarySet = ItemSet.create("Legendary", Color.FromHex("FFF2ED5E"))

    local timer t

    set g_MainItemSetLibrary = ItemSetLibrary.create()

    call g_MainItemSetLibrary.Add(commonSet, 8.0 ) 
    call g_MainItemSetLibrary.Add(rareSet, 4.0 )
    call g_MainItemSetLibrary.Add(epicSet, 2.0 )
    call g_MainItemSetLibrary.Add(legendarySet, 1.0)

    call commonSet.Add('afac', 10.0)
    call commonSet.Add('spsh', 20.0)
    call commonSet.Add('ajen', 30.0)

    call rareSet.Add('bgst', 10.0)
    call rareSet.Add('belv', 20.0)
    call rareSet.Add('bspd', 30.0)

    call epicSet.Add('cnob', 10.0)
    call epicSet.Add('ratc', 20.0)
    call epicSet.Add('clfm', 30.0)

    call legendarySet.Add('clsd', 10.0)
    call legendarySet.Add('crys', 20.0)
    call legendarySet.Add('dsum', 30.0)

    set t = CreateTimer()
    call TimerStart(t, 1.0, true, function Test)
    set t = null
    

  endfunction

endlibrary