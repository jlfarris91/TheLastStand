/*****************************************************************************
*
*    Vector<T> v1.1.8.4
*       by Bannar
*
*    Dynamic contiguous array.
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
*       macro DEFINE_VECTOR takes ACCESS, NAME, TYPE
*
*       macro DEFINE_STRUCT_VECTOR takes ACCESS, NAME, TYPE
*
*          ACCESS - encapsulation, choose restriction access
*            NAME - name of vector type
*            TYPE - type of values stored
*
*     Implementation notes:
*
*       - DEFINE_STRUCT_VECTOR macro purpose is to provide natural typecasting syntax for struct types.
*       - Vectors defined with DEFINE_STRUCT_VECTOR are inlined nicely into single create method and single integer array.
*
******************************************************************************
*
*    struct API:
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
*        |    Checks whether the vector is empty.
*        |
*        | method size takes nothing returns integer
*        |    Returns size of a vector.
*
*
*       Access:
*
*        | method operator [] takes integer index returns $TYPE$
*        |    Returns item at position index.
*        |
*        | method operator []= takes integer index, $TYPE$ value returns nothing
*        |    Sets item at index to value.
*        |
*        | method front takes nothing returns $TYPE$
*        |    Retrieves first element.
*        |
*        | method back takes nothing returns $TYPE$
*        |    Retrieves last element.
*        |
*        | method data takes nothing returns Table
*        |    Returns the underlying Table object.
*
*
*       Modifiers:
*
*        | method clear takes nothing returns nothing
*        |    Performs a flush operation on data table.
*        |
*        | method push takes $TYPE$ value returns thistype
*        |    Adds elements to the end.
*        |
*        | method pop takes nothing returns thistype
*        |    Removes the last element.
*        |
*        | method assign takes integer count, $TYPE$ value returns thistype
*        |    Assigns count elements replacing current data.
*        |
*        | method insert takes integer pos, integer count, $TYPE$ value returns thistype
*        |    Inserts count elements before position pos.
*        |
*        | method erase takes integer pos, integer count returns thistype
*        |    Erases count elements starting at position pos.
*
*
*****************************************************************************/
library VectorT requires Table, Alloc

//! runtextmacro DEFINE_VECTOR("", "IntegerVector", "integer")
// Run here any global vector types you want to be defined.

//! textmacro_once DEFINE_VECTOR takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$ extends array
    private Table table
    private integer length

    implement Alloc

    private method seT takes integer index, $TYPE$ value returns nothing
        set table.$TYPE$[index] = value
    endmethod

    private method get takes integer index returns $TYPE$
        return table.$TYPE$[index]
    endmethod

    private method assert_pos takes integer pos, string f returns boolean
        debug if pos < 0 or pos >= length then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"$NAME$::assert_pos failed at "+f+" for instance "+I2S(this)+". Index "+I2S(pos)+" is out of range.")
        debug endif

        return pos >= 0 and pos < length
    endmethod

    private method assert_range takes integer pos, string f returns boolean
        debug if pos < 0 or pos > length then
            debug call DisplayTimedTextToPlayer(GetLocalPlayer(),0,0,60,"$NAME$::assert_range failed at "+f+" for instance "+I2S(this)+". Iterator "+I2S(pos)+" is out of range.")
        debug endif

        return pos >= 0 and pos <= length
    endmethod

    method operator [] takes integer index returns $TYPE$
        debug if not assert_pos(index, "operator []") then
            debug return get(-1)
        debug endif

        return get(index)
    endmethod

    method operator []= takes integer index, $TYPE$ value returns nothing
        debug if not assert_pos(index, "operator []=") then
            debug return
        debug endif

        call seT(index, value)
    endmethod

    static method create takes nothing returns thistype
        local thistype this = allocate()
        set table = Table.create()
        set length = 0
        return this
    endmethod

    method clear takes nothing returns nothing
        set length = 0
        call table.flush()
    endmethod

    method destroy takes nothing returns nothing
        call clear()
        call table.destroy()
        set table = 0

        call deallocate()
    endmethod

    method front takes nothing returns $TYPE$
        return this[0]
    endmethod

    method back takes nothing returns $TYPE$
        return this[length-1]
    endmethod

    method data takes nothing returns Table
        return this.table
    endmethod

    method empty takes nothing returns boolean
        return length == 0
    endmethod

    method size takes nothing returns integer
        return length
    endmethod

    method push takes $TYPE$ value returns thistype
        call seT(length, value)
        set length = length + 1

        return this
    endmethod

    method pop takes nothing returns thistype
        if length > 0 then
            set length = length - 1
            call table.$TYPE$.remove(length)
        endif

        return this
    endmethod

    static method operator [] takes thistype other returns thistype
        local thistype instance = create()
        loop
            exitwhen instance.size() >= other.size()
            call instance.push(other[instance.size()])
        endloop

        return instance
    endmethod

    method assign takes integer count, $TYPE$ value returns thistype
        if count > 0 then
            call clear()
            loop
                exitwhen length >= count
                call push(value)
            endloop
        endif

        return this
    endmethod

    method insert takes integer pos, integer count, $TYPE$ value returns thistype
        local integer i

        if assert_range(pos, "insert") and count > 0 then
            set length = length + count
            set i = length - 1
            loop
                exitwhen i < (pos + count)
                call seT(i, get(i-count))
                set i = i - 1
            endloop

            set i = 0
            loop
                exitwhen i >= count
                call seT(pos+i, value)
                set i = i + 1
            endloop
        endif

        return this
    endmethod

    method erase takes integer pos, integer count returns thistype
        if assert_pos(pos, "erase") and count > 0 then
            if ( pos + count > length ) then
                set count = length - pos
            endif

            set pos = pos + count
            loop
                exitwhen pos >= length
                call seT(pos-count, get(pos))
                set pos = pos + 1
            endloop

            loop
                exitwhen count <= 0
                call pop()
                set count = count - 1
            endloop
        endif

        return this
    endmethod
endstruct
//! endtextmacro

//! textmacro_once DEFINE_STRUCT_VECTOR takes ACCESS, NAME, TYPE
$ACCESS$ struct $NAME$ extends array
    private delegate IntegerVector parent

    method operator[] takes integer index returns $TYPE$
        return parent[index]
    endmethod

    static method create takes nothing returns thistype
        local thistype this = IntegerVector.create()
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