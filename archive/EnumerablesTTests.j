library EnumerablesTTests initializer Init requires EnumerablesT, ListT, WeightedSetT, Common

  //! runtextmacro DEFINE_ENUMERABLE_T("", "integer")
  //! runtextmacro DEFINE_ARRAY_ENUMERATOR("", "MyArrayEnumerator", "MyArray", "integer")
  //! runtextmacro DEFINE_LIST_ENUMERATOR("", "IntegerListEnumerator", "IntegerList", "integer")
  //! runtextmacro DEFINE_LINQ_T("", "integer")

  struct MyArray

    public integer array myIntegers[5]

    public method operator [] takes integer i returns integer
      return this.myIntegers[i]
    endmethod

    public method operator []= takes integer i, integer value returns nothing
      set this.myIntegers[i] = value
    endmethod

    public method size takes nothing returns integer
      return this.myIntegers.size
    endmethod

    method GetEnumerator takes nothing returns IEnumerator_integer
      local IEnumerator_integer enum = MyArrayEnumerator.create(this)
      return enum
    endmethod
  endstruct

  struct MyList extends array
    private delegate IntegerList parent

    implement Alloc

    public static method create takes nothing returns thistype
      local thistype this = allocate()
      set this.parent = IntegerList.create()
      return this
    endmethod

    method GetEnumerator takes nothing returns IEnumerator_integer
      local IEnumerator_integer enum = IntegerListEnumerator.create(this.parent)
      return enum
    endmethod

  endstruct

  private function EnumerateIntegers takes integer value returns nothing
    call Debug.Log("foreach: " + I2S(value))
  endfunction

  private function Init takes nothing returns nothing

    local MyArray myArray = MyArray.create()
    local MyList myList = MyList.create()
    local WeightedIntegerSet mySet = WeightedIntegerSet.create()
    local integer i = 0
    local IEnumerator_integer enum

    loop 
      exitwhen i == 5
      set myArray[i] = i
      call myList.push(i * 2)
      call mySet.Add(i * 3, I2R(i))
      set i = i + 1
    endloop
    
    call Debug.Log("array: ")

    //! runtextmacro BeginEnumerate("myArray", "enum")
      call Debug.Log("array inline: " + I2S(enum.Current))
    //! runtextmacro EndEnumerate("enum")

    //! runtextmacro ForEach("integer", "myArray", "EnumerateIntegers")

    call Debug.Log("Any: " + B2S(Linq_integer_Any(myArray)))

    call Debug.Log("list: ")

    ////! runtextmacro BeginEnumerate("myList", "enum")
    //  call Debug.Log("list inline: " + I2S(enum.Current))
    ////! runtextmacro EndEnumerate("enum")

    //! runtextmacro ForEach("integer", "myList", "EnumerateIntegers")

    call Debug.Log("Any: " + B2S(Linq_integer_Any(myList)))

    call Debug.Log("set: ")

    ////! runtextmacro BeginEnumerate("mySet", "enum")
    //  call Debug.Log("set inline: " + I2S(enum.Current))
    ////! runtextmacro EndEnumerate("enum")

    //! runtextmacro ForEach("integer", "mySet", "EnumerateIntegers")

    call Debug.Log("Any: " + B2S(Linq_integer_Any(mySet)))

  endfunction
endlibrary