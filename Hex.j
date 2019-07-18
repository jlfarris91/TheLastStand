library Hex
  
  private function HexInt2HexDigit takes integer hexInt returns string

    if hexInt >= 0 and hexInt <= 9 then
      return I2S(hexInt)
    elseif hexInt == 10 then
      return "A"
    elseif hexInt == 11 then
      return "B"
    elseif hexInt == 12 then
      return "C"
    elseif hexInt == 13 then
      return "D"
    elseif hexInt == 14 then
      return "E"
    endif

    return "F"

  endfunction
  
  private function HexDigit2HexInt takes string hexDigit returns integer

    local integer hexInt

    if StringLength(hexDigit) != 1 then
      return -1
    endif
    
    set hexDigit = StringCase(hexDigit, true)
    set hexInt = S2I(hexDigit)

    if hexDigit == "0" or hexInt != 0 then
      return hexInt
    elseif hexDigit == "A" then
      return 10
    elseif hexDigit == "B" then
      return 11
    elseif hexDigit == "C" then
      return 12
    elseif hexDigit == "D" then
      return 13
    elseif hexDigit == "E" then
      return 14
    elseif hexDigit == "F" then
      return 15
    endif

    return -1

  endfunction

  function Hex2Int takes string hex returns integer

    local integer length = StringLength(hex)
    local integer s = R2I( Pow(16.0, length - 1) )
    local integer i = 0
    local string digit = ""
    local integer result = 0

    if ( hex == "FFFFFFFF" ) then
      return -1
    endif

    loop
      exitwhen i >= length

      set digit = SubString(hex, i, i + 1)
      set result = result + HexDigit2HexInt(digit) * s

      set s = s / 16
      set i = i + 1

    endloop

    return result

  endfunction

  function Int2Hex takes integer int returns string

    local integer temp = int
    local integer tempOld = temp
    local integer rest
    local string hex = ""

    if ( int == -1 ) then
      return "FFFFFFFF"
    endif

    loop
      set temp = temp/16
      set rest = tempOld - temp*16
      set tempOld = temp
      set hex = HexInt2HexDigit(rest) + hex
      exitwhen temp == 0
    endloop
    return hex

  endfunction

endlibrary