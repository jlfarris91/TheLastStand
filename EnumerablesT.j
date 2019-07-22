library EnumerablesT requires FuncT, Alloc

  //! textmacro DEFINE_ENUMERABLE_T takes ACCESS, TVALUE
  $ACCESS$ interface IEnumerator_$TVALUE$
    method operator Current takes nothing returns $TVALUE$
    method operator CanMoveNext takes nothing returns boolean
    method MoveNext takes nothing returns nothing
  endinterface

  $ACCESS$ interface IEnumerable_$TVALUE$
    method GetEnumerator takes nothing returns IEnumerator_$TVALUE$
  endinterface

  $ACCESS$ function interface IEnumerable_$TVALUE$_Action takes $TVALUE$ value returns nothing
  $ACCESS$ function interface IEnumerable_$TVALUE$_Predicate takes $TVALUE$ value returns boolean

  $ACCESS$ function IEnumerable_ForEach_$TVALUE$ takes IEnumerable_$TVALUE$ enumerable, IEnumerable_$TVALUE$_Action action returns nothing
    local IEnumerator_$TVALUE$ enumerator = enumerable.GetEnumerator()
    loop
      exitwhen not enumerator.CanMoveNext
      call enumerator.MoveNext()
      call action.evaluate(enumerator.Current)
    endloop
    call enumerator.destroy()
  endfunction
  //! endtextmacro

  //! textmacro IMPLEMENT_ENUMERABLE_T takes ACCESS, TVALUE, TENUM
  $ACCESS$ method GetEnumerator takes nothing returns IEnumerator_$TVALUE$
    local IEnumerator_$TVALUE$ enum = $TENUM$.create(this)
    return enum
  endmethod
  //! endtextmacro

  //! textmacro BeginEnumerate takes ENUMERABLE, VAR
  set $VAR$ = $ENUMERABLE$.GetEnumerator()
  loop
    exitwhen not $VAR$.CanMoveNext
    call $VAR$.MoveNext()
  //! endtextmacro

  //! textmacro EndEnumerate takes VAR
  endloop
  call $VAR$.destroy()
  set $VAR$ = 0
  //! endtextmacro

  //! textmacro ForEach takes TVALUE, ENUM, ACTION
  call IEnumerable_ForEach_$TVALUE$($ENUM$, $ACTION$)
  //! endtextmacro

  //! textmacro DEFINE_ARRAY_ENUMERATOR takes ACCESS, NAME, TARRAY, TVALUE
  $ACCESS$ struct $NAME$ extends array
  
    private integer currentIndex
    private $TARRAY$ enumerable

    implement Alloc

    public static method create takes $TARRAY$ enumerable returns thistype
      local thistype this = allocate()
      set this.enumerable = enumerable
      set this.currentIndex = -1
      call BJDebugMsg("[ArrayEnumerator.create] created for enumerable " + I2S(enumerable))
      return this
    endmethod

    public method operator Current takes nothing returns $TVALUE$
      call BJDebugMsg("[ArrayEnumerator.Current] index: " + I2S(this.currentIndex) + " current: " + I2S(this.enumerable[this.currentIndex]))
      return this.enumerable[this.currentIndex]
    endmethod

    public method operator CanMoveNext takes nothing returns boolean
      call BJDebugMsg("[ArrayEnumerator.CanMoveNext] index: " + I2S(this.currentIndex) + " < " + I2S(this.enumerable.size()))
      return this.currentIndex < this.enumerable.size() - 1
    endmethod

    public method MoveNext takes nothing returns nothing
      set this.currentIndex = this.currentIndex + 1
      call BJDebugMsg("[ArrayEnumerator.MoveNext] index: " + I2S(this.currentIndex))
    endmethod

  endstruct
  //! endtextmacro
  
  //! textmacro DEFINE_LIST_ENUMERATOR takes ACCESS, NAME, TLIST, TVALUE
  $ACCESS$ struct $NAME$ extends array
  
    private $TLIST$Item node
    private boolean hasMovedOnce

    implement Alloc

    public static method create takes $TLIST$ list returns thistype
      local thistype this = allocate()
      set this.node = list.first
      set this.hasMovedOnce = false
      return this
    endmethod

    public method operator Current takes nothing returns $TVALUE$
      return this.node.data
    endmethod

    public method operator CanMoveNext takes nothing returns boolean
      return this.node != 0 and this.node.next != 0
    endmethod

    public method MoveNext takes nothing returns nothing
      if this.hasMovedOnce then
        set this.node = this.node.next
      endif
      set this.hasMovedOnce = true
    endmethod

  endstruct
  //! endtextmacro

  //! textmacro DEFINE_LINQ_T takes ACCESS, TVALUE

  $ACCESS$ function Linq_$TVALUE$_Any takes IEnumerable_$TVALUE$ enumerable returns boolean
    local IEnumerator_$TVALUE$ enum = enumerable.GetEnumerator()
    local boolean any = enum.CanMoveNext
    call enum.destroy()
    return any
  endfunction

  $ACCESS$ function Linq_$TVALUE$_AnyWhere takes IEnumerable_$TVALUE$ enumerable, IEnumerable_$TVALUE$_Predicate predicate returns boolean
    local IEnumerator_$TVALUE$ enumerator = enumerable.GetEnumerator()
    local boolean result = false
    loop
      exitwhen not enumerator.CanMoveNext
      if ( predicate.evaluate(enumerator.Current) ) then
        set result = true
        exitwhen true
      endif
      call enumerator.MoveNext()
    endloop
    call enumerator.destroy()
    return result
  endfunction

  $ACCESS$ function Linq_$TVALUE$_All takes IEnumerable_$TVALUE$ enumerable, IEnumerable_$TVALUE$_Predicate predicate returns boolean
    local IEnumerator_$TVALUE$ enumerator = enumerable.GetEnumerator()
    local boolean result = true
    loop
      exitwhen not enumerator.CanMoveNext
      if ( not predicate.evaluate(enumerator.Current) ) then
        set result = false
        exitwhen true
      endif
      call enumerator.MoveNext()
    endloop
    call enumerator.destroy()
    return result
  endfunction

  // $ACCESS$ function Where takes IEnumerable_$TVALUE$ enumerable, IEnumerable_$TVALUE$_Predicate predicate returns IEnumerable_$TVALUE$
    
  // endfunction

  //! endtextmacro

endlibrary