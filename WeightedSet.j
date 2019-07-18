/*****************************************************************************
*
*    List<T> v2.1.2.3
*       by Bannar
*
*    Doubly-linked list.
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
*       macro DEFINE_LIST takes ACCESS, NAME, TYPE
*
*       macro DEFINE_STRUCT_LIST takes ACCESS, NAME, TYPE
*
*          ACCESS - encapsulation, choose restriction access
*            NAME - name of list type
*            TYPE - type of values stored
*
*     Implementation notes:
*
*       - DEFINE_STRUCT_LIST macro purpose is to provide natural typecasting syntax for struct types.
*       - <NAME>Item structs inline directly into hashtable operations thus generate basically no code.
*       - Lists defined with DEFINE_STRUCT_LIST are inlined nicely into single create method and single integer array.
*
******************************************************************************
*
*    struct API:
*
*       struct <NAME>Item:
*
*        | <TYPE> data
*        | <NAME>Item next
*        | <NAME>Item prev
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
*        | method empty takes nothing returns boolean
*        |    Checks whether the list is empty.
*        |
*        | method size takes nothing returns integer
*        |    Returns size of a list.
*
*
*       Access:
*
*        | readonly <NAME>Item first
*        | readonly <NAME>Item last
*        |
*        | method front takes nothing returns $TYPE$
*        |    Retrieves first element.
*        |
*        | method back takes nothing returns $TYPE$
*        |    Retrieves last element.
*
*
*       Modifiers:
*
*        | method clear takes nothing returns nothing
*        |    Flushes list and recycles its nodes.
*        |
*        | method add takes $TYPE$ value returns thistype
*        |    Adds elements to the end.
*        |
*        | method unshift takes $TYPE$ value returns thistype
*        |    Adds elements to the front.
*        |
*        | method pop takes nothing returns thistype
*        |    Removes the last element.
*        |
*        | method shift takes nothing returns thistype
*        |    Removes the first element.
*        |
*        | method find takes $TYPE$ value returns $NAME$Item
*        |    Returns the first node which data equals value.
*        |
*        | method erase takes $NAME$Item node returns boolean
*        |    Removes node from the list, returns true on success.
*        |
*        | method removeElem takes $TYPE$ value returns thistype
*        |    Removes first element that equals value from the list.
*
*
*****************************************************************************/
library WeightedSetT requires ListT

globals
  public integer KEY_ITEM_DATA = -1
  public integer KEY_ITEM_WEIGHT = -2
  public integer KEY_ITEM_NEXT = -3
  public integer KEY_ITEM_PREV = -4
  public integer KEY_OWNER = -5
endglobals

//! runtextmacro DEFINE_WEIGHTEDSET("", "WeightedIntegerSet", "integer")

//! textmacro_once DEFINE_WEIGHTEDSET takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$Item extends array
    // No default ctor and dctor due to limited array size

    method operator data takes nothing returns $TYPE$
        return Table(this).$TYPE$[WeightedSetT_KEY_ITEM_DATA]
    endmethod
    method operator data= takes $TYPE$ value returns nothing
        set Table(this).$TYPE$[WeightedSetT_KEY_ITEM_DATA] = value
    endmethod

    method operator weight takes nothing returns real
        return Table(this).real[WeightedSetT_KEY_ITEM_WEIGHT]
    endmethod
    method operator weight= takes real value returns nothing
        set Table(this).real[WeightedSetT_KEY_ITEM_WEIGHT] = value
    endmethod

    method operator next takes nothing returns thistype
        return Table(this)[WeightedSetT_KEY_ITEM_NEXT]
    endmethod
    method operator next= takes thistype value returns nothing
        set Table(this)[WeightedSetT_KEY_ITEM_NEXT] = value
    endmethod

    method operator prev takes nothing returns thistype
        return Table(this)[WeightedSetT_KEY_ITEM_PREV]
    endmethod
    method operator prev= takes thistype value returns nothing
        set Table(this)[WeightedSetT_KEY_ITEM_PREV] = value
    endmethod
endstruct

$ACCESS$ struct $NAME$ extends array
    readonly $NAME$Item first
    readonly $NAME$Item last
    private integer count
    private real totalWeight

    implement Alloc

    private static method setNodeOwner takes $NAME$Item node, $NAME$ owner returns nothing
        set Table(node)[WeightedSetT_KEY_OWNER] = owner
    endmethod

    private static method getNodeOwner takes $NAME$Item node returns thistype
        return Table(node)[WeightedSetT_KEY_OWNER]
    endmethod

    private method createNode takes $TYPE$ value, real weight returns $NAME$Item
        local $NAME$Item node = Table.create()
        set node.data = value
        set node.weight = weight
        set this.totalWeight = this.totalWeight + node.weight
        call setNodeOwner(node, this) // ownership
        return node
    endmethod

    private method deleteNode takes $NAME$Item node returns nothing
        set this.totalWeight = this.totalWeight - node.weight
        call Table(node).destroy() // also removes ownership
    endmethod

    static method create takes nothing returns thistype
        local thistype this = allocate()
        set count = 0
        return this
    endmethod

    method clear takes nothing returns nothing
        local $NAME$Item node = first
        local $NAME$Item temp

        loop // recycle all Table indexes
            exitwhen 0 == node
            set temp = node.next
            call deleteNode(node)
            set node = temp
        endloop

        set first = 0
        set last = 0
        set count = 0
    endmethod

    method destroy takes nothing returns nothing
        call clear()
        call deallocate()
    endmethod

    method front takes nothing returns $TYPE$
        return first.data
    endmethod

    method back takes nothing returns $TYPE$
        return last.data
    endmethod

    method empty takes nothing returns boolean
        return count == 0
    endmethod

    method size takes nothing returns integer
        return count
    endmethod

    method getTotalWeight takes nothing returns real
        return totalWeight
    endmethod

    method add takes $TYPE$ value, real weight returns thistype
        local $NAME$Item node = createNode(value, weight)

        if not empty() then
            set last.next = node
            set node.prev = last
        else
            set first = node
            set node.prev = 0
        endif

        set last = node
        set node.next = 0
        set count = count + 1
        return this
    endmethod

    method pop takes nothing returns thistype
        local $NAME$Item node

        if not empty() then
            set node = last
            set last = last.prev

            if last == 0 then
                set first = 0
            else
                set last.next = 0
            endif

            call deleteNode(node)
            set count = count - 1
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"$NAME$::pop failed for instance "+I2S(this)+". List is empty.")
        endif
        return this
    endmethod

    static method operator [] takes thistype other returns thistype
        local thistype instance = create()
        local $NAME$Item node = other.first

        loop
            exitwhen node == 0
            call instance.add(node.data, node.weight)
            set node = node.next
        endloop

        return instance
    endmethod

    method find takes $TYPE$ value returns $NAME$Item
        local $NAME$Item node = first
        loop
            exitwhen node == 0 or node.data == value
            set node = node.next
        endloop
        return node
    endmethod

    method erase takes $NAME$Item node returns boolean
        if getNodeOwner(node) == this then // match ownership
            if node == first then
                call shift()
            elseif node == last then
                call pop()
            else
                set node.prev.next = node.next
                set node.next.prev = node.prev
                call deleteNode(node)
                set count = count - 1
            endif
            return true
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"$NAME$::erase failed for instance "+I2S(this)+". Attempted to remove invalid node "+I2S(node)+".")
        endif
        return false
    endmethod

    method remove takes $NAME$Item node returns boolean
        debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"Method $NAME$::remove is obsolete, use $NAME$::erase instead.")
        return erase(node)
    endmethod

    method removeElem takes $TYPE$ value returns thistype
        local $NAME$Item node = find(value)
        if node != 0 then
            call erase(node)
        endif
        return this
    endmethod

    method GetRandomElem takes nothing returns $TYPE$
        local $NAME$Item node
        local real rand
        local $TYPE$ pickedValue

        set rand = GetRandomReal(0.0, this.totalWeight)
        set node = this.first

        loop
            exitwhen node == 0

            if ( rand >= 0.0 and rand < node.weight ) then
              set pickedValue = node.data
              exitwhen true
            endif

            set rand = rand - node.weight

            set node = node.next
        endloop

        return pickedValue
    endmethod

    method unshift takes $TYPE$ value, real weight returns thistype
        local $NAME$Item node = createNode(value, weight)

        if not empty() then
            set first.prev = node
            set node.next = first
        else
            set last = node
            set node.next = 0
        endif

        set first = node
        set node.prev = 0
        set count = count + 1
        return this
    endmethod

    method shift takes nothing returns thistype
        local $NAME$Item node

        if not empty() then
            set node = first
            set first = first.next

            if first == 0 then
                set last = 0
            else
                set first.prev = 0
            endif

            call deleteNode(node)
            set count = count - 1
        debug else
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"$NAME$::shift failed for instance "+I2S(this)+". List is empty.")
        endif
        return this
    endmethod

endstruct
//! endtextmacro

//! textmacro_once DEFINE_STRUCT_WEIGHTEDSET takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$Item extends array
    // Cannot inherit methods via delegate due to limited array size
    method operator data takes nothing returns $TYPE$
        return WeightedIntegerSetItem(this).data
    endmethod
    method operator data= takes $TYPE$ value returns nothing
        set WeightedIntegerSetItem(this).data = value
    endmethod

    method operator weight takes nothing returns real
        return WeightedIntegerSetItem(this).weight
    endmethod
    method operator weight= takes real value returns nothing
        set WeightedIntegerSetItem(this).weight = value
    endmethod

    method operator next takes nothing returns thistype
        return WeightedIntegerSetItem(this).next
    endmethod
    method operator next= takes thistype value returns nothing
        set WeightedIntegerSetItem(this).next = value
    endmethod

    method operator prev takes nothing returns thistype
        return WeightedIntegerSetItem(this).prev
    endmethod
    method operator prev= takes thistype value returns nothing
        set WeightedIntegerSetItem(this).prev = value
    endmethod
endstruct

$ACCESS$ struct $NAME$ extends array
    private delegate WeightedIntegerSet parent

    static method create takes nothing returns thistype
        local thistype this = WeightedIntegerSet.create()
        set parent = this
        return this
    endmethod

    method front takes nothing returns $TYPE$
        return parent.front()
    endmethod

    method back takes nothing returns $TYPE$
        return parent.back()
    endmethod
endstruct
//! endtextmacro

endlibrary