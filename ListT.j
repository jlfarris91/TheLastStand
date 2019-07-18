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
*        | method push takes $TYPE$ value returns thistype
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
library ListT requires Table, Alloc

//! runtextmacro DEFINE_LIST("", "IntegerList", "integer")
// Run here any global list types you want to be defined.

//! textmacro_once DEFINE_LIST takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$Item extends array
    // No default ctor and dctor due to limited array size

    method operator data takes nothing returns $TYPE$
        return Table(this).$TYPE$[-1] // hashtable[ node, -1 ] = data
    endmethod
    method operator data= takes $TYPE$ value returns nothing
        set Table(this).$TYPE$[-1] = value
    endmethod

    method operator next takes nothing returns thistype
        return Table(this)[-2] // hashtable[ node, -2 ] = next
    endmethod
    method operator next= takes thistype value returns nothing
        set Table(this)[-2] = value
    endmethod

    method operator prev takes nothing returns thistype
        return Table(this)[-3] // hashtable[ node, -3 ] = prev
    endmethod
    method operator prev= takes thistype value returns nothing
        set Table(this)[-3] = value
    endmethod
endstruct

$ACCESS$ struct $NAME$ extends array
    readonly $NAME$Item first
    readonly $NAME$Item last
    private integer count

    implement Alloc

    private static method setNodeOwner takes $NAME$Item node, $NAME$ owner returns nothing
        set Table(node)[-4] = owner
    endmethod

    private static method getNodeOwner takes $NAME$Item node returns thistype
        return Table(node)[-4]
    endmethod

    private method createNode takes $TYPE$ value returns $NAME$Item
        local $NAME$Item node = Table.create()
        set node.data = value
        call setNodeOwner(node, this) // ownership
        return node
    endmethod

    private method deleteNode takes $NAME$Item node returns nothing
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

    method push takes $TYPE$ value returns thistype
        local $NAME$Item node = createNode(value)

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

    method unshift takes $TYPE$ value returns thistype
        local $NAME$Item node = createNode(value)

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

    static method operator [] takes thistype other returns thistype
        local thistype instance = create()
        local $NAME$Item node = other.first

        loop
            exitwhen node == 0
            call instance.push(node.data)
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
endstruct
//! endtextmacro

//! textmacro_once DEFINE_STRUCT_LIST takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$Item extends array
    // Cannot inherit methods via delegate due to limited array size
    method operator data takes nothing returns $TYPE$
        return IntegerListItem(this).data
    endmethod
    method operator data= takes $TYPE$ value returns nothing
        set IntegerListItem(this).data = value
    endmethod

    method operator next takes nothing returns thistype
        return IntegerListItem(this).next
    endmethod
    method operator next= takes thistype value returns nothing
        set IntegerListItem(this).next = value
    endmethod

    method operator prev takes nothing returns thistype
        return IntegerListItem(this).prev
    endmethod
    method operator prev= takes thistype value returns nothing
        set IntegerListItem(this).prev = value
    endmethod
endstruct

$ACCESS$ struct $NAME$ extends array
    private delegate IntegerList parent

    static method create takes nothing returns thistype
        local thistype this = IntegerList.create()
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