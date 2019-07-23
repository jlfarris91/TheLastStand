library Tags

  function CreateTag takes real x, real y, real z, real size, string msg, real r, real g, real b returns nothing
    local location l = Location(x, y)
    call CreateTextTagLocBJ( msg, l, z, size, r, g, b, 0)
    // ========================================
    call SetTextTagPermanentBJ( GetLastCreatedTextTag(), false )
    call SetTextTagFadepointBJ( GetLastCreatedTextTag(), 1.00 )
    call SetTextTagLifespanBJ( GetLastCreatedTextTag(), 3.00 )
    call SetTextTagVelocityBJ( GetLastCreatedTextTag(), 64, 90 )
    call RemoveLocation(l)
    set l = null
  endfunction

  function CreateMaterialsTag takes real x, real y, integer mats returns nothing
    call CreateTag(x, y, 32.0, 10.0, "+" + I2S(mats), 100.0, 80.0, 0.0)
    call AddSpecialEffect("UI\\Feedback\\GoldCredit\\GoldCredit.mdl", x, y)
    call DestroyEffectBJ(GetLastCreatedEffectBJ())
  endfunction

endlibrary