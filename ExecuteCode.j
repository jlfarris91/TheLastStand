library ExecuteCode initializer Init

  globals
    private constant integer MAX_NUM_PLAYERS = 24
    private force g_ForceExec
  endglobals

  function ExecuteCode takes code c returns nothing
    call ForForce(g_ForceExec, c)
  endfunction

  private function Init takes nothing returns nothing
    local integer i = 0
    local player p
    local playerslotstate slotState
    local boolean isPlaying

    set g_ForceExec = CreateForce()

    loop
      exitwhen i > MAX_NUM_PLAYERS

      set p = ConvertedPlayer(i)

      if ( GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING ) then
        call ForceAddPlayer(g_ForceExec, p)
        exitwhen true
      endif

      set p = null
      
      set i = i + 1
    endloop

  endfunction  

endlibrary