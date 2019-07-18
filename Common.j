library Common

  struct Debug

    public static method Log takes string msg returns nothing

      call DisplayTextToForce(GetPlayersAll(), msg)

    endmethod

    public static method LogWarning takes string msg returns nothing

      call Log("|cFFFFFF00WARNING: " + msg + "|r")

    endmethod

    public static method LogError takes string msg returns nothing

      call Log("|cFFFF0000ERROR: " + msg + "|r")

    endmethod

  endstruct

endlibrary

