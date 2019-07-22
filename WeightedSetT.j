/*****************************************************************************
*
*    WeightedSet<T> v2.1.2.3
*       by Ozymandias
*
*    A set with elements assigned a weight.
*
******************************************************************************
*
*    Requirements:
*
*       Table by Bribe
*          hiveworkshop.com/threads/snippet-new-table.188084/
*
*       Alloc - choose whatever you like
*          e.g.: by Sevion hiveworkshop.com/threads/snippet-alloc.192348/
*
******************************************************************************
*
*    Implementation:
*
*       macro DEFINE_WEIGHTEDSET takes ACCESS, NAME, TVALUE
*
*       macro DEFINE_STRUCT_WEIGHTEDSET takes ACCESS, NAME, TVALUE
*
*          ACCESS - encapsulation, choose restriction access
*            NAME - name of set type
*            TVALUE - type of values stored
*
*     Implementation notes:
*
*       - DEFINE_STRUCT_WEIGHTEDSET macro purpose is to provide natural typecasting syntax for struct types.
*       - <NAME>Item structs inline directly into hashtable operations thus generate basically no code.
*       - Lists defined with DEFINE_STRUCT_WEIGHTEDSET are inlined nicely into single create method and single integer array.
*
******************************************************************************
*
*    struct API:
*
*       struct <NAME>Item:
*
*        | <TVALUE> Data
*        | real Weight
*        | <NAME>Item Next
*        | <NAME>Item Prev
*
*
*       General:
*
*        | static method create takes nothing returns thistype
*        |    Default ctor.
*        |
*        | static method operator [] takes thistype other returns thistype
*        |    Copy ctor.
*        |
*        | method destroy takes nothing returns nothing
*        |    Default dctor.
*        |
*        | method IsEmpty takes nothing returns boolean
*        |    Checks whether the set is empty.
*        |
*        | method Count takes nothing returns integer
*        |    Returns the number of items in the set.
*
*
*       Access:
*
*        | readonly <NAME>Item first
*        | readonly <NAME>Item last
*
*
*       Modifiers:
*
*        | method Clear takes nothing returns nothing
*        |    Flushes the set and recycles its nodes.
*        |
*        | method Add takes $TVALUE$ value, real weight returns thistype
*        |    Adds an element to the set with the given weight.
*        |
*        | method Remove takes $TVALUE$ value returns thistype
*        |    Removes first element that equals value from the set.
*        |
*        | method GetRandom takes nothing returns $TVALUE$
*        |    Gets a random element from the set
*
*
*****************************************************************************/
library WeightedSetT requires Table, Alloc, ExecuteCode

    globals
        public constant integer KEY_ITEM_DATA = -1
        public constant integer KEY_ITEM_WEIGHT = -2
        public constant integer KEY_ITEM_NEXT = -3
        public constant integer KEY_ITEM_PREV = -4
        public constant integer KEY_OWNER = -5
        public integer g_EnumItem = 0
        public integer g_EnumSet = 0
    endglobals

//! runtextmacro DEFINE_WEIGHTEDSET("", "WeightedIntegerSet", "integer")

//! textmacro_once DEFINE_WEIGHTEDSET takes ACCESS, NAME, TVALUE
$ACCESS$ struct $NAME$Item extends array
    // No default ctor and dctor due to limited array size

    method operator Data takes nothing returns $TVALUE$
        return Table(this).$TVALUE$[WeightedSetT_KEY_ITEM_DATA]
    endmethod
    method operator Data= takes $TVALUE$ value returns nothing
        set Table(this).$TVALUE$[WeightedSetT_KEY_ITEM_DATA] = value
    endmethod

    method operator Weight takes nothing returns real
        return Table(this).real[WeightedSetT_KEY_ITEM_WEIGHT]
    endmethod
    method operator Weight= takes real value returns nothing
        set Table(this).real[WeightedSetT_KEY_ITEM_WEIGHT] = value
    endmethod

    method operator Next takes nothing returns thistype
        return Table(this)[WeightedSetT_KEY_ITEM_NEXT]
    endmethod
    method operator Next= takes thistype value returns nothing
        set Table(this)[WeightedSetT_KEY_ITEM_NEXT] = value
    endmethod

    method operator Prev takes nothing returns thistype
        return Table(this)[WeightedSetT_KEY_ITEM_PREV]
    endmethod
    method operator Prev= takes thistype value returns nothing
        set Table(this)[WeightedSetT_KEY_ITEM_PREV] = value
    endmethod
endstruct

function interface $NAME$Filter takes $TVALUE$ value returns boolean

$ACCESS$ struct $NAME$ extends array
    readonly $NAME$Item first
    readonly $NAME$Item last
    private integer count
    private real totalWeight

    implement Alloc

    // Default ctor
    static method create takes nothing returns thistype
        local thistype this = allocate()
        set count = 0
        return this
    endmethod

    // Copy ctor
    static method operator [] takes thistype other returns thistype
        local thistype instance = create()
        local $NAME$Item node = other.first

        loop
            exitwhen node == 0
            call instance.Add(node.Data, node.Weight)
            set node = node.Next
        endloop

        return instance
    endmethod

    method destroy takes nothing returns nothing
        call Clear()
        call deallocate()
    endmethod

    method operator IsEmpty takes nothing returns boolean
        return count == 0
    endmethod

    method operator Count takes nothing returns integer
        return count
    endmethod

    method operator TotalWeight takes nothing returns real
        return totalWeight
    endmethod

    private static method SetNodeOwner takes $NAME$Item node, $NAME$ owner returns nothing
        set Table(node)[WeightedSetT_KEY_OWNER] = owner
    endmethod

    private static method GetNodeOwner takes $NAME$Item node returns thistype
        return Table(node)[WeightedSetT_KEY_OWNER]
    endmethod

    private method CreateNode takes $TVALUE$ value, real weight returns $NAME$Item
        local $NAME$Item node = Table.create()
        set node.Data = value
        set node.Weight = weight
        set this.totalWeight = this.totalWeight + weight
        call SetNodeOwner(node, this) // ownership
        return node
    endmethod

    private method DeleteNode takes $NAME$Item node returns nothing
        set this.totalWeight = this.totalWeight - node.Weight
        call Table(node).destroy() // also removes ownership
    endmethod

    private method RemoveNode takes $NAME$Item node returns boolean
        if GetNodeOwner(node) != this then // match ownership
            debug call Debug.LogError("$NAME$::RemoveNode failed for instance "+I2S(this)+". Node "+I2S(node)+" does not belong to set.")
            return false
        endif

        if IsEmpty then
            debug call Debug.LogError("$NAME$::RemoveNode failed for instance "+I2S(this)+". Set is empty.")
            return false
        endif

        if node == first then
            set node = first
            set first = first.Next
            set first.Prev = 0
        elseif node == last then
            set node = last
            set last = last.Prev
            set last.Next = 0
        else
            set node.Prev.Next = node.Next
            set node.Next.Prev = node.Prev
        endif

        call DeleteNode(node)
        set count = count - 1

        return true
    endmethod

    method Clear takes nothing returns nothing
        local $NAME$Item node = first
        local $NAME$Item temp

        loop // recycle all Table indexes
            exitwhen 0 == node
            set temp = node.Next
            call DeleteNode(node)
            set node = temp
        endloop

        set first = 0
        set last = 0
        set count = 0
    endmethod

    method Add takes $TVALUE$ value, real weight returns thistype
        local $NAME$Item node = CreateNode(value, weight)

        if not IsEmpty then
            set last.Next = node
            set node.Prev = last
        else
            set first = node
            set node.Prev = 0
        endif

        set last = node
        set node.Next = 0
        set count = count + 1
        return this
    endmethod

    method Find takes $TVALUE$ value returns $NAME$Item
        local $NAME$Item node = first
        loop
            exitwhen node == 0 or node.Data == value
            set node = node.Next
        endloop
        return node
    endmethod

    method FindWhere takes $NAME$Filter filter returns $NAME$Item
        local $NAME$Item node = first
        loop
            exitwhen node == 0 or ( filter.evaluate(node.Data) == true )
            set node = node.Next
        endloop
        return node
    endmethod

    method Remove takes $TVALUE$ element returns thistype
        local $NAME$Item node = this.Find(element)
        if node != 0 then
            call this.RemoveNode(node)
        endif
        return this
    endmethod

    method GetRandom takes nothing returns $TVALUE$
        local $NAME$Item node
        local real rand
        local $TVALUE$ pickedValue

        set rand = GetRandomReal(0.0, this.totalWeight)
        set node = this.first

        loop
            exitwhen node == 0

            if ( rand >= 0.0 and rand < node.Weight ) then
              set pickedValue = node.Data
              exitwhen true
            endif

            set rand = rand - node.Weight

            set node = node.Next
        endloop

        return pickedValue
    endmethod

    method GetChance takes $TVALUE$ element returns real
        local $NAME$Item node = this.Find(element)
        if node != 0 then
            return node.Weight / this.totalWeight
        endif
        return 0.0
    endmethod

    method ForEach takes code callback returns nothing
        local $NAME$Item node = this.first
        loop
            exitwhen node == 0
            set WeightedSetT_g_EnumItem = node
            set WeightedSetT_g_EnumSet = this
            call ExecuteCode(callback)
            set node = node.Next
        endloop
        set WeightedSetT_g_EnumItem = 0
        set WeightedSetT_g_EnumSet = 0
    endmethod

    method ForEachWhere takes code callback, $NAME$Filter filter returns nothing
        local $NAME$Item node = this.first
        loop
            exitwhen node == 0
            if ( filter.evaluate(node.Data) == true ) then
                set WeightedSetT_g_EnumItem = node
                set WeightedSetT_g_EnumSet = this
                call ExecuteCode(callback)
            endif
            set node = node.Next
        endloop
        set WeightedSetT_g_EnumItem = 0
        set WeightedSetT_g_EnumSet = 0
    endmethod

endstruct

function GetEnum$NAME$Item takes nothing returns $NAME$Item
    return WeightedSetT_g_EnumItem
endfunction

function GetEnum$NAME$ takes nothing returns $NAME$
    return WeightedSetT_g_EnumSet
endfunction

//! endtextmacro

//! textmacro_once DEFINE_STRUCT_WEIGHTEDSET takes ACCESS, NAME, TVALUE
$ACCESS$ struct $NAME$Item extends array
    // Cannot inherit methods via delegate due to limited array size
    method operator Data takes nothing returns $TVALUE$
        return WeightedIntegerSetItem(this).Data
    endmethod
    method operator Data= takes $TVALUE$ value returns nothing
        set WeightedIntegerSetItem(this).Data = value
    endmethod

    method operator Weight takes nothing returns real
        return WeightedIntegerSetItem(this).Weight
    endmethod
    method operator Weight= takes real value returns nothing
        set WeightedIntegerSetItem(this).Weight = value
    endmethod

    method operator Next takes nothing returns thistype
        return WeightedIntegerSetItem(this).Next
    endmethod
    method operator Next= takes thistype value returns nothing
        set WeightedIntegerSetItem(this).Next = value
    endmethod

    method operator Prev takes nothing returns thistype
        return WeightedIntegerSetItem(this).Prev
    endmethod
    method operator Prev= takes thistype value returns nothing
        set WeightedIntegerSetItem(this).Prev = value
    endmethod
endstruct

$ACCESS$ struct $NAME$ extends array
    private delegate WeightedIntegerSet parent

    static method create takes nothing returns thistype
        local thistype this = WeightedIntegerSet.create()
        set parent = this
        return this
    endmethod
endstruct

//! endtextmacro

endlibrary