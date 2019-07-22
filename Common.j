library Common

  struct Debug

    public static method Log takes string msg returns nothing

      call BJDebugMsg(msg)
      //call DisplayTextToForce(GetPlayersAll(), msg)

    endmethod

    public static method LogWarning takes string msg returns nothing

      call Log("|cFFFFFF00WARNING: " + msg + "|r")

    endmethod

    public static method LogError takes string msg returns nothing

      call Log("|cFFFF0000ERROR: " + msg + "|r")

    endmethod

  endstruct

  function B2S takes boolean b returns string
    if b == true then
      return "True"
    else
      return "False"
    endif
  endfunction

  function S2B takes string s returns boolean
    set s = StringCase(s, false)
    if (s == "true" or s == "1") then
      return true
    else
      return false
    endif
  endfunction

  function GetDistanceSqr takes real x1, real y1, real x2, real y2 returns real
    return (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)
  endfunction

  function IsUnitInvulnerable takes unit u returns boolean
    local boolean isInvulnerable = GetUnitAbilityLevelSwapped('Avul', u) > 0
    set u = null
    return isInvulnerable
  endfunction

endlibrary