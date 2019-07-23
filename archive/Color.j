library Colors requires Hex

  struct Color

    private integer valueR
    private integer valueG
    private integer valueB
    private integer valueA
    private string hexARGB
    private string hexRGB

    private method UpdateHexString takes nothing returns nothing

      local string astr = Int2Hex(this.valueA)
      local string rstr = Int2Hex(this.valueR)
      local string gstr = Int2Hex(this.valueG)
      local string bstr = Int2Hex(this.valueB)

      set this.hexARGB = astr + rstr + gstr + bstr
      set this.hexRGB = rstr + gstr + bstr

    endmethod

    public static method FromRGB takes integer r, integer g, integer b returns Color

      local thistype color = allocate()
      set color.valueA = 255
      set color.valueR = r
      set color.valueG = g
      set color.valueB = b
      call color.UpdateHexString()
      return color

    endmethod

    public static method FromARGB takes integer a, integer r, integer g, integer b returns Color

      local thistype color = allocate()
      set color.valueA = a
      set color.valueR = r
      set color.valueG = g
      set color.valueB = b
      call color.UpdateHexString()
      return color

    endmethod

    public static method FromHex takes string hex returns Color

      local integer l = StringLength(hex)
      local thistype color = allocate()
      local integer x = 0

      set color.valueA = 255

      if ( l == 2 ) then
        set x = Hex2Int(SubString(hex, 0, 2))
        set color.valueR = x
        set color.valueG = x
        set color.valueB = x
      elseif ( l == 6 ) then
        set color.valueR = Hex2Int(SubString(hex, 0, 2))
        set color.valueG = Hex2Int(SubString(hex, 2, 4))
        set color.valueB = Hex2Int(SubString(hex, 4, 6))
      elseif ( l == 8 ) then
        set color.valueA = Hex2Int(SubString(hex, 0, 2))
        set color.valueR = Hex2Int(SubString(hex, 2, 4))
        set color.valueG = Hex2Int(SubString(hex, 4, 6))
        set color.valueB = Hex2Int(SubString(hex, 6, 8))
      else
        call Debug.LogError("[Color.fromHex] Cannot parse color from hex string " + hex)
      endif

      call color.UpdateHexString()

      return color

    endmethod

    public method ColorizeStringARGB takes string str returns string
      return "|c" + hexARGB + str + "|r"
    endmethod

    public method ColorizeStringRGB takes string str returns string
      return "|c" + hexRGB + str + "|r"
    endmethod

    public method operator r takes nothing returns integer
      return this.valueR
    endmethod

    public method operator r= takes integer r returns nothing
      set this.valueR = r
      call UpdateHexString()
    endmethod

    public method operator g takes nothing returns integer
      return this.valueG
    endmethod

    public method operator g= takes integer g returns nothing
      set this.valueG = g
      call UpdateHexString()
    endmethod

    public method operator b takes nothing returns integer
      return this.valueB
    endmethod

    public method operator b= takes integer b returns nothing
      set this.valueB = b
      call UpdateHexString()
    endmethod

    public method operator a takes nothing returns integer
      return this.valueA
    endmethod

    public method operator a= takes integer a returns nothing
      set this.valueA = a
      call UpdateHexString()
    endmethod

  endstruct

endlibrary