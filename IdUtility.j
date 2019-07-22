library IdUtility requires Bitwise

  globals

    private string g_Ascii = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

  endglobals

  // Credits to AceHart for this.
  private function Char2Id takes string c returns integer
    local integer i = 0
    local string t

    loop
      set t = SubString(g_Ascii,i,i + 1)
      exitwhen t == null or t == c
      set i = i + 1
    endloop
    // 0-9
    if i < 10 then
      return i + 48
    // A-Z
    elseif i < 36 then
      return i + 55
    endif
    // a-z
    return i + 61
  endfunction

  // Credits to AceHart for this.
  private function Id2Char takes integer i returns string
        
    // 0-9
    if ( i >= 48 and i < 58 ) then
      set i = i - 48
    // A-Z
    elseif ( i >= 65 and i < 91 ) then
      set i = i - 55
    // a-z
    elseif ( i >= 97 and i < 123 ) then
      set i = i - 61
    // Unsupported ascii char
    else
      return ""
    endif
    return SubString(g_Ascii, i, i + 1)
  endfunction

  // Credits to AceHart for this.
  function String2Id takes string s returns integer
    return ((Char2Id(SubString(s,0,1)) * 256 + Char2Id(SubString(s,1,2))) * 256 + Char2Id(SubString(s,2,3))) * 256 + Char2Id(SubString(s,3,4))
  endfunction

  function Id2String takes integer i returns string
    local integer c = 0
    local integer mask = 0xFF
    local integer digit = 0
    local string s = ""
    loop
      exitwhen i == 0
      set digit = Bitwise.AND32(i, mask)
      set s = Id2Char(digit) + s
      set i = Bitwise.shiftr(i, 8)
    endloop
    return s
  endfunction

endlibrary