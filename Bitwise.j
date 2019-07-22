/*****************************************************************************
*
*    Bitwise v1.0.0.1
*       by Nestharus, Magtheridon96 & Bannar
*
*    Provides convinient way to perform bitwise operations.
*
******************************************************************************
*
*    struct lbyte:
*
*       static constant method operator [] takes integer val returns integer
*
*
*    struct rbyte:
*
*       static constant method operator [] takes integer val returns integer
*
*
*    struct sbyte:
*
*        static constant method AND takes integer sub1, integer sub2 returns integer
*
*        static constant method OR takes integer sub1, integer sub2 returns integer
*
*        static constant method XOR takes integer sub1, integer sub2 returns integer
*
******************************************************************************
*
*    struct Bitwise:
*
*       1 byte - 8 bits
*
*          static constant method NOT takes integer byte returns integer
*
*          static constant method AND takes integer byte1, integer byte2 returns integer
*
*          static constant method OR takes integer byte1, integer byte2 returns integer
*
*          static constant method XOR takes integer byte1, integer byte2 returns integer
*
*
*       Bit shifts
*
*          static method shiftl takes integer byte, integer shift returns integer
*
*          static method shiftr takes integer byte, integer shift returns integer
*
*          static method rotl takes integer byte, integer shift returns integer
*
*          static method rotr takes integer byte, integer shift returns integer
*
*
*       4 bytes - 32 bits
*
*          static constant method NOT32 takes integer int returns integer
*
*          static method AND32 takes integer int1, integer int2 returns integer
*
*          static method OR32 takes integer int1, integer int2 returns integer
*
*          static method XOR32 takes integer int1, integer int2 returns integer
*
******************************************************************************/
library Bitwise

    globals
        private integer array leftByte
        private integer array rightByte
        private integer array andData
        private integer array orData
        private integer array xorData
        private integer array powShift
    endglobals

    globals
        private integer b1
        private integer b2
    endglobals

    private module lbyteInit
        private static method onInit takes nothing returns nothing
            local integer i16 = 0x0
            local integer i256 = 0x0
            local integer i
            loop
                exitwhen i256 >= 0x100
                set i = 0
                loop
                    exitwhen i >= 0x10
                    set leftByte[i256] = i16
                    set i256 = i256 + 1
                    set i = i + 1
                endloop
                set i16 = i16 + 1
            endloop
        endmethod
    endmodule

    struct lbyte extends array
        static constant method operator [] takes integer val returns integer
            return leftByte[val]
        endmethod
    
        implement lbyteInit
    endstruct

    private module rbyteInit
        private static method onInit takes nothing returns nothing
            local integer i256 = 0x0
            local integer i16
            loop
                exitwhen i256 >= 0x100
                set i16 = 0
                loop
                    exitwhen i16 >= 0x10
                    set rightByte[i256] = i16
                    set i256 = i256 + 1
                    set i16 = i16 + 1
                endloop
            endloop
        endmethod
    endmodule

    struct rbyte extends array
        static constant method operator [] takes integer val returns integer
            return rightByte[val]
        endmethod
    
        implement rbyteInit
    endstruct

    struct sbyte extends array
        static constant method AND takes integer sub1, integer sub2 returns integer
            return andData[sub1 * 0x10 + sub2]
        endmethod

        static constant method OR takes integer sub1, integer sub2 returns integer
            return orData[sub1 * 0x10 + sub2]
        endmethod

        static constant method XOR takes integer sub1, integer sub2 returns integer
            return xorData[sub1 * 0x10 + sub2]
        endmethod
    endstruct

    private keyword BitwiseInit

    struct Bitwise extends array
        static constant method NOT takes integer byte returns integer
            return 0xff - byte
        endmethod

        static constant method AND takes integer byte1, integer byte2 returns integer
            return sbyte.AND(lbyte[byte1], lbyte[byte2]) * 0x10 + sbyte.AND(rbyte[byte1], rbyte[byte2])
        endmethod

        static constant method OR takes integer byte1, integer byte2 returns integer
            return sbyte.OR(lbyte[byte1], lbyte[byte2]) * 0x10 + sbyte.OR(rbyte[byte1], rbyte[byte2])
        endmethod

        static constant method XOR takes integer byte1, integer byte2 returns integer
            return sbyte.XOR(lbyte[byte1], lbyte[byte2])*0x10 + sbyte.XOR(rbyte[byte1], rbyte[byte2])
        endmethod

        static method shiftl takes integer byte, integer shift returns integer
            return byte * powShift[shift]
        endmethod

        static method shiftr takes integer byte, integer shift returns integer
            return byte / powShift[shift]
        endmethod

        static method rotl takes integer byte, integer shift returns integer
            return OR( shiftl(byte, shift), shiftr(byte, 4*8 - shift) )
        endmethod

        static method rotr takes integer byte, integer shift returns integer
            return OR( shiftr(byte, shift), shiftl(byte, 4*8 - shift) )
        endmethod

        static constant method NOT32 takes integer int returns integer
            return -int - 1
        endmethod

        static method AND32 takes integer int1, integer int2 returns integer
            if (0 > int1) then
                set int1 = -2147483648 + int1
                set b1 = 1
            else
                set b1 = 0
            endif
            if (0 > int2) then
                set int2 = -2147483648 + int2
                set b2 = 1
            else
                set b2 = 0
            endif
           
            return AND(b1*128 + int1/0x1000000, b2*128 + int2/0x1000000)*0x1000000 + /*
                */ AND((int1 - int1/0x1000000*0x1000000)/0x10000, (int2 - int2/0x1000000*0x1000000)/0x10000) * 0x10000 + /*
                */ AND((int1 - int1/0x10000*0x10000)/0x100, (int2 - int2/0x10000*0x10000)/0x100) * 0x100 + /*
                */ AND(int1 - int1/0x100*0x100, int2 - int2/0x100*0x100)
        endmethod

        static method OR32 takes integer int1, integer int2 returns integer
            if (0 > int1) then
                set int1 = -2147483648 + int1
                set b1 = 1
            else
                set b1 = 0
            endif
            if (0 > int2) then
                set int2 = -2147483648 + int2
                set b2 = 1
            else
                set b2 = 0
            endif
           
            return OR(b1*128 + int1/0x1000000, b2*128 + int2/0x1000000)*0x1000000 + /*
                */ OR((int1 - int1/0x1000000*0x1000000)/0x10000, (int2 - int2/0x1000000*0x1000000)/0x10000) * 0x10000 + /*
                */ OR((int1 - int1/0x10000*0x10000)/0x100, (int2 - int2/0x10000*0x10000)/0x100) * 0x100 + /*
                */ OR(int1 - int1/0x100*0x100, int2 - int2/0x100*0x100)
        endmethod

        static method XOR32 takes integer int1, integer int2 returns integer
            if (0 > int1) then
                set int1 = -2147483648 + int1
                set b1 = 1
            else
                set b1 = 0
            endif
            if (0 > int2) then
                set int2 = -2147483648 + int2
                set b2 = 1
            else
                set b2 = 0
            endif
            
            return XOR(b1*128 + int1/0x1000000, b2*128 + int2/0x1000000)*0x1000000 + /*
                */ XOR((int1 - int1/0x1000000*0x1000000)/0x10000, (int2 - int2/0x1000000*0x1000000)/0x10000) * 0x10000 + /*
                */ XOR((int1 - int1/0x10000*0x10000)/0x100, (int2 - int2/0x10000*0x10000)/0x100) * 0x100 + /*
                */ XOR(int1 - int1/0x100*0x100, int2 - int2/0x100*0x100)
        endmethod

        implement BitwiseInit
    endstruct

// Trust me, you don't want to scroll down there
    private module BitwiseInit
        private static method initShiftData takes nothing returns nothing
            local integer bit = 0
            loop
                exitwhen bit > 0x20
                set powShift[bit] = R2I(Pow(2, bit))
                set bit = bit + 1
            endloop
        endmethod

        private static method initANDData takes nothing returns nothing
            set andData[0x00] = 0x0
            set andData[0x01] = 0x0
            set andData[0x02] = 0x0
            set andData[0x03] = 0x0
            set andData[0x04] = 0x0
            set andData[0x05] = 0x0
            set andData[0x06] = 0x0
            set andData[0x07] = 0x0
            set andData[0x08] = 0x0
            set andData[0x09] = 0x0
            set andData[0x0a] = 0x0
            set andData[0x0b] = 0x0
            set andData[0x0c] = 0x0
            set andData[0x0d] = 0x0
            set andData[0x0e] = 0x0
            set andData[0x0f] = 0x0
            set andData[0x10] = 0x0
            set andData[0x11] = 0x1
            set andData[0x12] = 0x0
            set andData[0x13] = 0x1
            set andData[0x14] = 0x0
            set andData[0x15] = 0x1
            set andData[0x16] = 0x0
            set andData[0x17] = 0x1
            set andData[0x18] = 0x0
            set andData[0x19] = 0x1
            set andData[0x1a] = 0x0
            set andData[0x1b] = 0x1
            set andData[0x1c] = 0x0
            set andData[0x1d] = 0x1
            set andData[0x1e] = 0x0
            set andData[0x1f] = 0x1
            set andData[0x20] = 0x0
            set andData[0x21] = 0x0
            set andData[0x22] = 0x2
            set andData[0x23] = 0x2
            set andData[0x24] = 0x0
            set andData[0x25] = 0x0
            set andData[0x26] = 0x2
            set andData[0x27] = 0x2
            set andData[0x28] = 0x0
            set andData[0x29] = 0x0
            set andData[0x2a] = 0x2
            set andData[0x2b] = 0x2
            set andData[0x2c] = 0x0
            set andData[0x2d] = 0x0
            set andData[0x2e] = 0x2
            set andData[0x2f] = 0x2
            set andData[0x30] = 0x0
            set andData[0x31] = 0x1
            set andData[0x32] = 0x2
            set andData[0x33] = 0x3
            set andData[0x34] = 0x0
            set andData[0x35] = 0x1
            set andData[0x36] = 0x2
            set andData[0x37] = 0x3
            set andData[0x38] = 0x0
            set andData[0x39] = 0x1
            set andData[0x3a] = 0x2
            set andData[0x3b] = 0x3
            set andData[0x3c] = 0x0
            set andData[0x3d] = 0x1
            set andData[0x3e] = 0x2
            set andData[0x3f] = 0x3
            set andData[0x40] = 0x0
            set andData[0x41] = 0x0
            set andData[0x42] = 0x0
            set andData[0x43] = 0x0
            set andData[0x44] = 0x4
            set andData[0x45] = 0x4
            set andData[0x46] = 0x4
            set andData[0x47] = 0x4
            set andData[0x48] = 0x0
            set andData[0x49] = 0x0
            set andData[0x4a] = 0x0
            set andData[0x4b] = 0x0
            set andData[0x4c] = 0x4
            set andData[0x4d] = 0x4
            set andData[0x4e] = 0x4
            set andData[0x4f] = 0x4
            set andData[0x50] = 0x0
            set andData[0x51] = 0x1
            set andData[0x52] = 0x0
            set andData[0x53] = 0x1
            set andData[0x54] = 0x4
            set andData[0x55] = 0x5
            set andData[0x56] = 0x4
            set andData[0x57] = 0x5
            set andData[0x58] = 0x0
            set andData[0x59] = 0x1
            set andData[0x5a] = 0x0
            set andData[0x5b] = 0x1
            set andData[0x5c] = 0x4
            set andData[0x5d] = 0x5
            set andData[0x5e] = 0x4
            set andData[0x5f] = 0x5
            set andData[0x60] = 0x0
            set andData[0x61] = 0x0
            set andData[0x62] = 0x2
            set andData[0x63] = 0x2
            set andData[0x64] = 0x4
            set andData[0x65] = 0x4
            set andData[0x66] = 0x6
            set andData[0x67] = 0x6
            set andData[0x68] = 0x0
            set andData[0x69] = 0x0
            set andData[0x6a] = 0x2
            set andData[0x6b] = 0x2
            set andData[0x6c] = 0x4
            set andData[0x6d] = 0x4
            set andData[0x6e] = 0x6
            set andData[0x6f] = 0x6
            set andData[0x70] = 0x0
            set andData[0x71] = 0x1
            set andData[0x72] = 0x2
            set andData[0x73] = 0x3
            set andData[0x74] = 0x4
            set andData[0x75] = 0x5
            set andData[0x76] = 0x6
            set andData[0x77] = 0x7
            set andData[0x78] = 0x0
            set andData[0x79] = 0x1
            set andData[0x7a] = 0x2
            set andData[0x7b] = 0x3
            set andData[0x7c] = 0x4
            set andData[0x7d] = 0x5
            set andData[0x7e] = 0x6
            set andData[0x7f] = 0x7
            set andData[0x80] = 0x0
            set andData[0x81] = 0x0
            set andData[0x82] = 0x0
            set andData[0x83] = 0x0
            set andData[0x84] = 0x0
            set andData[0x85] = 0x0
            set andData[0x86] = 0x0
            set andData[0x87] = 0x0
            set andData[0x88] = 0x8
            set andData[0x89] = 0x8
            set andData[0x8a] = 0x8
            set andData[0x8b] = 0x8
            set andData[0x8c] = 0x8
            set andData[0x8d] = 0x8
            set andData[0x8e] = 0x8
            set andData[0x8f] = 0x8
            set andData[0x90] = 0x0
            set andData[0x91] = 0x1
            set andData[0x92] = 0x0
            set andData[0x93] = 0x1
            set andData[0x94] = 0x0
            set andData[0x95] = 0x1
            set andData[0x96] = 0x0
            set andData[0x97] = 0x1
            set andData[0x98] = 0x8
            set andData[0x99] = 0x9
            set andData[0x9a] = 0x8
            set andData[0x9b] = 0x9
            set andData[0x9c] = 0x8
            set andData[0x9d] = 0x9
            set andData[0x9e] = 0x8
            set andData[0x9f] = 0x9
            set andData[0xa0] = 0x0
            set andData[0xa1] = 0x0
            set andData[0xa2] = 0x2
            set andData[0xa3] = 0x2
            set andData[0xa4] = 0x0
            set andData[0xa5] = 0x0
            set andData[0xa6] = 0x2
            set andData[0xa7] = 0x2
            set andData[0xa8] = 0x8
            set andData[0xa9] = 0x8
            set andData[0xaa] = 0xa
            set andData[0xab] = 0xa
            set andData[0xac] = 0x8
            set andData[0xad] = 0x8
            set andData[0xae] = 0xa
            set andData[0xaf] = 0xa
            set andData[0xb0] = 0x0
            set andData[0xb1] = 0x1
            set andData[0xb2] = 0x2
            set andData[0xb3] = 0x3
            set andData[0xb4] = 0x0
            set andData[0xb5] = 0x1
            set andData[0xb6] = 0x2
            set andData[0xb7] = 0x3
            set andData[0xb8] = 0x8
            set andData[0xb9] = 0x9
            set andData[0xba] = 0xa
            set andData[0xbb] = 0xb
            set andData[0xbc] = 0x8
            set andData[0xbd] = 0x9
            set andData[0xbe] = 0xa
            set andData[0xbf] = 0xb
            set andData[0xc0] = 0x0
            set andData[0xc1] = 0x0
            set andData[0xc2] = 0x0
            set andData[0xc3] = 0x0
            set andData[0xc4] = 0x4
            set andData[0xc5] = 0x4
            set andData[0xc6] = 0x4
            set andData[0xc7] = 0x4
            set andData[0xc8] = 0x8
            set andData[0xc9] = 0x8
            set andData[0xca] = 0x8
            set andData[0xcb] = 0x8
            set andData[0xcc] = 0xc
            set andData[0xcd] = 0xc
            set andData[0xce] = 0xc
            set andData[0xcf] = 0xc
            set andData[0xd0] = 0x0
            set andData[0xd1] = 0x1
            set andData[0xd2] = 0x0
            set andData[0xd3] = 0x1
            set andData[0xd4] = 0x4
            set andData[0xd5] = 0x5
            set andData[0xd6] = 0x4
            set andData[0xd7] = 0x5
            set andData[0xd8] = 0x8
            set andData[0xd9] = 0x9
            set andData[0xda] = 0x8
            set andData[0xdb] = 0x9
            set andData[0xdc] = 0xc
            set andData[0xdd] = 0xd
            set andData[0xde] = 0xc
            set andData[0xdf] = 0xd
            set andData[0xe0] = 0x0
            set andData[0xe1] = 0x0
            set andData[0xe2] = 0x2
            set andData[0xe3] = 0x2
            set andData[0xe4] = 0x4
            set andData[0xe5] = 0x4
            set andData[0xe6] = 0x6
            set andData[0xe7] = 0x6
            set andData[0xe8] = 0x8
            set andData[0xe9] = 0x8
            set andData[0xea] = 0xa
            set andData[0xeb] = 0xa
            set andData[0xec] = 0xc
            set andData[0xed] = 0xc
            set andData[0xee] = 0xe
            set andData[0xef] = 0xe
            set andData[0xf0] = 0x0
            set andData[0xf1] = 0x1
            set andData[0xf2] = 0x2
            set andData[0xf3] = 0x3
            set andData[0xf4] = 0x4
            set andData[0xf5] = 0x5
            set andData[0xf6] = 0x6
            set andData[0xf7] = 0x7
            set andData[0xf8] = 0x8
            set andData[0xf9] = 0x9
            set andData[0xfa] = 0xa
            set andData[0xfb] = 0xb
            set andData[0xfc] = 0xc
            set andData[0xfd] = 0xd
            set andData[0xfe] = 0xe
            set andData[0xff] = 0xf
        endmethod

        private static method initORData takes nothing returns nothing
            set orData[0x00] = 0x0
            set orData[0x01] = 0x1
            set orData[0x02] = 0x2
            set orData[0x03] = 0x3
            set orData[0x04] = 0x4
            set orData[0x05] = 0x5
            set orData[0x06] = 0x6
            set orData[0x07] = 0x7
            set orData[0x08] = 0x8
            set orData[0x09] = 0x9
            set orData[0x0a] = 0xa
            set orData[0x0b] = 0xb
            set orData[0x0c] = 0xc
            set orData[0x0d] = 0xd
            set orData[0x0e] = 0xe
            set orData[0x0f] = 0xf
            set orData[0x10] = 0x1
            set orData[0x11] = 0x1
            set orData[0x12] = 0x3
            set orData[0x13] = 0x3
            set orData[0x14] = 0x5
            set orData[0x15] = 0x5
            set orData[0x16] = 0x7
            set orData[0x17] = 0x7
            set orData[0x18] = 0x9
            set orData[0x19] = 0x9
            set orData[0x1a] = 0xb
            set orData[0x1b] = 0xb
            set orData[0x1c] = 0xd
            set orData[0x1d] = 0xd
            set orData[0x1e] = 0xf
            set orData[0x1f] = 0xf
            set orData[0x20] = 0x2
            set orData[0x21] = 0x3
            set orData[0x22] = 0x2
            set orData[0x23] = 0x3
            set orData[0x24] = 0x6
            set orData[0x25] = 0x7
            set orData[0x26] = 0x6
            set orData[0x27] = 0x7
            set orData[0x28] = 0xa
            set orData[0x29] = 0xb
            set orData[0x2a] = 0xa
            set orData[0x2b] = 0xb
            set orData[0x2c] = 0xe
            set orData[0x2d] = 0xf
            set orData[0x2e] = 0xe
            set orData[0x2f] = 0xf
            set orData[0x30] = 0x3
            set orData[0x31] = 0x3
            set orData[0x32] = 0x3
            set orData[0x33] = 0x3
            set orData[0x34] = 0x7
            set orData[0x35] = 0x7
            set orData[0x36] = 0x7
            set orData[0x37] = 0x7
            set orData[0x38] = 0xb
            set orData[0x39] = 0xb
            set orData[0x3a] = 0xb
            set orData[0x3b] = 0xb
            set orData[0x3c] = 0xf
            set orData[0x3d] = 0xf
            set orData[0x3e] = 0xf
            set orData[0x3f] = 0xf
            set orData[0x40] = 0x4
            set orData[0x41] = 0x5
            set orData[0x42] = 0x6
            set orData[0x43] = 0x7
            set orData[0x44] = 0x4
            set orData[0x45] = 0x5
            set orData[0x46] = 0x6
            set orData[0x47] = 0x7
            set orData[0x48] = 0xc
            set orData[0x49] = 0xd
            set orData[0x4a] = 0xe
            set orData[0x4b] = 0xf
            set orData[0x4c] = 0xc
            set orData[0x4d] = 0xd
            set orData[0x4e] = 0xe
            set orData[0x4f] = 0xf
            set orData[0x50] = 0x5
            set orData[0x51] = 0x5
            set orData[0x52] = 0x7
            set orData[0x53] = 0x7
            set orData[0x54] = 0x5
            set orData[0x55] = 0x5
            set orData[0x56] = 0x7
            set orData[0x57] = 0x7
            set orData[0x58] = 0xd
            set orData[0x59] = 0xd
            set orData[0x5a] = 0xf
            set orData[0x5b] = 0xf
            set orData[0x5c] = 0xd
            set orData[0x5d] = 0xd
            set orData[0x5e] = 0xf
            set orData[0x5f] = 0xf
            set orData[0x60] = 0x6
            set orData[0x61] = 0x7
            set orData[0x62] = 0x6
            set orData[0x63] = 0x7
            set orData[0x64] = 0x6
            set orData[0x65] = 0x7
            set orData[0x66] = 0x6
            set orData[0x67] = 0x7
            set orData[0x68] = 0xe
            set orData[0x69] = 0xf
            set orData[0x6a] = 0xe
            set orData[0x6b] = 0xf
            set orData[0x6c] = 0xe
            set orData[0x6d] = 0xf
            set orData[0x6e] = 0xe
            set orData[0x6f] = 0xf
            set orData[0x70] = 0x7
            set orData[0x71] = 0x7
            set orData[0x72] = 0x7
            set orData[0x73] = 0x7
            set orData[0x74] = 0x7
            set orData[0x75] = 0x7
            set orData[0x76] = 0x7
            set orData[0x77] = 0x7
            set orData[0x78] = 0xf
            set orData[0x79] = 0xf
            set orData[0x7a] = 0xf
            set orData[0x7b] = 0xf
            set orData[0x7c] = 0xf
            set orData[0x7d] = 0xf
            set orData[0x7e] = 0xf
            set orData[0x7f] = 0xf
            set orData[0x80] = 0x8
            set orData[0x81] = 0x9
            set orData[0x82] = 0xa
            set orData[0x83] = 0xb
            set orData[0x84] = 0xc
            set orData[0x85] = 0xd
            set orData[0x86] = 0xe
            set orData[0x87] = 0xf
            set orData[0x88] = 0x8
            set orData[0x89] = 0x9
            set orData[0x8a] = 0xa
            set orData[0x8b] = 0xb
            set orData[0x8c] = 0xc
            set orData[0x8d] = 0xd
            set orData[0x8e] = 0xe
            set orData[0x8f] = 0xf
            set orData[0x90] = 0x9
            set orData[0x91] = 0x9
            set orData[0x92] = 0xb
            set orData[0x93] = 0xb
            set orData[0x94] = 0xd
            set orData[0x95] = 0xd
            set orData[0x96] = 0xf
            set orData[0x97] = 0xf
            set orData[0x98] = 0x9
            set orData[0x99] = 0x9
            set orData[0x9a] = 0xb
            set orData[0x9b] = 0xb
            set orData[0x9c] = 0xd
            set orData[0x9d] = 0xd
            set orData[0x9e] = 0xf
            set orData[0x9f] = 0xf
            set orData[0xa0] = 0xa
            set orData[0xa1] = 0xb
            set orData[0xa2] = 0xa
            set orData[0xa3] = 0xb
            set orData[0xa4] = 0xe
            set orData[0xa5] = 0xf
            set orData[0xa6] = 0xe
            set orData[0xa7] = 0xf
            set orData[0xa8] = 0xa
            set orData[0xa9] = 0xb
            set orData[0xaa] = 0xa
            set orData[0xab] = 0xb
            set orData[0xac] = 0xe
            set orData[0xad] = 0xf
            set orData[0xae] = 0xe
            set orData[0xaf] = 0xf
            set orData[0xb0] = 0xb
            set orData[0xb1] = 0xb
            set orData[0xb2] = 0xb
            set orData[0xb3] = 0xb
            set orData[0xb4] = 0xf
            set orData[0xb5] = 0xf
            set orData[0xb6] = 0xf
            set orData[0xb7] = 0xf
            set orData[0xb8] = 0xb
            set orData[0xb9] = 0xb
            set orData[0xba] = 0xb
            set orData[0xbb] = 0xb
            set orData[0xbc] = 0xf
            set orData[0xbd] = 0xf
            set orData[0xbe] = 0xf
            set orData[0xbf] = 0xf
            set orData[0xc0] = 0xc
            set orData[0xc1] = 0xd
            set orData[0xc2] = 0xe
            set orData[0xc3] = 0xf
            set orData[0xc4] = 0xc
            set orData[0xc5] = 0xd
            set orData[0xc6] = 0xe
            set orData[0xc7] = 0xf
            set orData[0xc8] = 0xc
            set orData[0xc9] = 0xd
            set orData[0xca] = 0xe
            set orData[0xcb] = 0xf
            set orData[0xcc] = 0xc
            set orData[0xcd] = 0xd
            set orData[0xce] = 0xe
            set orData[0xcf] = 0xf
            set orData[0xd0] = 0xd
            set orData[0xd1] = 0xd
            set orData[0xd2] = 0xf
            set orData[0xd3] = 0xf
            set orData[0xd4] = 0xd
            set orData[0xd5] = 0xd
            set orData[0xd6] = 0xf
            set orData[0xd7] = 0xf
            set orData[0xd8] = 0xd
            set orData[0xd9] = 0xd
            set orData[0xda] = 0xf
            set orData[0xdb] = 0xf
            set orData[0xdc] = 0xd
            set orData[0xdd] = 0xd
            set orData[0xde] = 0xf
            set orData[0xdf] = 0xf
            set orData[0xe0] = 0xe
            set orData[0xe1] = 0xf
            set orData[0xe2] = 0xe
            set orData[0xe3] = 0xf
            set orData[0xe4] = 0xe
            set orData[0xe5] = 0xf
            set orData[0xe6] = 0xe
            set orData[0xe7] = 0xf
            set orData[0xe8] = 0xe
            set orData[0xe9] = 0xf
            set orData[0xea] = 0xe
            set orData[0xeb] = 0xf
            set orData[0xec] = 0xe
            set orData[0xed] = 0xf
            set orData[0xee] = 0xe
            set orData[0xef] = 0xf
            set orData[0xf0] = 0xf
            set orData[0xf1] = 0xf
            set orData[0xf2] = 0xf
            set orData[0xf3] = 0xf
            set orData[0xf4] = 0xf
            set orData[0xf5] = 0xf
            set orData[0xf6] = 0xf
            set orData[0xf7] = 0xf
            set orData[0xf8] = 0xf
            set orData[0xf9] = 0xf
            set orData[0xfa] = 0xf
            set orData[0xfb] = 0xf
            set orData[0xfc] = 0xf
            set orData[0xfd] = 0xf
            set orData[0xfe] = 0xf
            set orData[0xff] = 0xf
        endmethod

        private static method initXORData takes nothing returns nothing
            set xorData[0x0] = 0x0
            set xorData[0x1] = 0x1
            set xorData[0x2] = 0x2
            set xorData[0x3] = 0x3
            set xorData[0x4] = 0x4
            set xorData[0x5] = 0x5
            set xorData[0x6] = 0x6
            set xorData[0x7] = 0x7
            set xorData[0x8] = 0x8
            set xorData[0x9] = 0x9
            set xorData[0xa] = 0xa
            set xorData[0xb] = 0xb
            set xorData[0xc] = 0xc
            set xorData[0xd] = 0xd
            set xorData[0xe] = 0xe
            set xorData[0xf] = 0xf
            set xorData[0x10] = 0x1
            set xorData[0x11] = 0x0
            set xorData[0x12] = 0x3
            set xorData[0x13] = 0x2
            set xorData[0x14] = 0x5
            set xorData[0x15] = 0x4
            set xorData[0x16] = 0x7
            set xorData[0x17] = 0x6
            set xorData[0x18] = 0x9
            set xorData[0x19] = 0x8
            set xorData[0x1a] = 0xb
            set xorData[0x1b] = 0xa
            set xorData[0x1c] = 0xd
            set xorData[0x1d] = 0xc
            set xorData[0x1e] = 0xf
            set xorData[0x1f] = 0xe
            set xorData[0x20] = 0x2
            set xorData[0x21] = 0x3
            set xorData[0x22] = 0x0
            set xorData[0x23] = 0x1
            set xorData[0x24] = 0x6
            set xorData[0x25] = 0x7
            set xorData[0x26] = 0x4
            set xorData[0x27] = 0x5
            set xorData[0x28] = 0xa
            set xorData[0x29] = 0xb
            set xorData[0x2a] = 0x8
            set xorData[0x2b] = 0x9
            set xorData[0x2c] = 0xe
            set xorData[0x2d] = 0xf
            set xorData[0x2e] = 0xc
            set xorData[0x2f] = 0xd
            set xorData[0x30] = 0x3
            set xorData[0x31] = 0x2
            set xorData[0x32] = 0x1
            set xorData[0x33] = 0x0
            set xorData[0x34] = 0x7
            set xorData[0x35] = 0x6
            set xorData[0x36] = 0x5
            set xorData[0x37] = 0x4
            set xorData[0x38] = 0xb
            set xorData[0x39] = 0xa
            set xorData[0x3a] = 0x9
            set xorData[0x3b] = 0x8
            set xorData[0x3c] = 0xf
            set xorData[0x3d] = 0xe
            set xorData[0x3e] = 0xd
            set xorData[0x3f] = 0xc
            set xorData[0x40] = 0x4
            set xorData[0x41] = 0x5
            set xorData[0x42] = 0x6
            set xorData[0x43] = 0x7
            set xorData[0x44] = 0x0
            set xorData[0x45] = 0x1
            set xorData[0x46] = 0x2
            set xorData[0x47] = 0x3
            set xorData[0x48] = 0xc
            set xorData[0x49] = 0xd
            set xorData[0x4a] = 0xe
            set xorData[0x4b] = 0xf
            set xorData[0x4c] = 0x8
            set xorData[0x4d] = 0x9
            set xorData[0x4e] = 0xa
            set xorData[0x4f] = 0xb
            set xorData[0x50] = 0x5
            set xorData[0x51] = 0x4
            set xorData[0x52] = 0x7
            set xorData[0x53] = 0x6
            set xorData[0x54] = 0x1
            set xorData[0x55] = 0x0
            set xorData[0x56] = 0x3
            set xorData[0x57] = 0x2
            set xorData[0x58] = 0xd
            set xorData[0x59] = 0xc
            set xorData[0x5a] = 0xf
            set xorData[0x5b] = 0xe
            set xorData[0x5c] = 0x9
            set xorData[0x5d] = 0x8
            set xorData[0x5e] = 0xb
            set xorData[0x5f] = 0xa
            set xorData[0x60] = 0x6
            set xorData[0x61] = 0x7
            set xorData[0x62] = 0x4
            set xorData[0x63] = 0x5
            set xorData[0x64] = 0x2
            set xorData[0x65] = 0x3
            set xorData[0x66] = 0x0
            set xorData[0x67] = 0x1
            set xorData[0x68] = 0xe
            set xorData[0x69] = 0xf
            set xorData[0x6a] = 0xc
            set xorData[0x6b] = 0xd
            set xorData[0x6c] = 0xa
            set xorData[0x6d] = 0xb
            set xorData[0x6e] = 0x8
            set xorData[0x6f] = 0x9
            set xorData[0x70] = 0x7
            set xorData[0x71] = 0x6
            set xorData[0x72] = 0x5
            set xorData[0x73] = 0x4
            set xorData[0x74] = 0x3
            set xorData[0x75] = 0x2
            set xorData[0x76] = 0x1
            set xorData[0x77] = 0x0
            set xorData[0x78] = 0xf
            set xorData[0x79] = 0xe
            set xorData[0x7a] = 0xd
            set xorData[0x7b] = 0xc
            set xorData[0x7c] = 0xb
            set xorData[0x7d] = 0xa
            set xorData[0x7e] = 0x9
            set xorData[0x7f] = 0x8
            set xorData[0x80] = 0x8
            set xorData[0x81] = 0x9
            set xorData[0x82] = 0xa
            set xorData[0x83] = 0xb
            set xorData[0x84] = 0xc
            set xorData[0x85] = 0xd
            set xorData[0x86] = 0xe
            set xorData[0x87] = 0xf
            set xorData[0x88] = 0x0
            set xorData[0x89] = 0x1
            set xorData[0x8a] = 0x2
            set xorData[0x8b] = 0x3
            set xorData[0x8c] = 0x4
            set xorData[0x8d] = 0x5
            set xorData[0x8e] = 0x6
            set xorData[0x8f] = 0x7
            set xorData[0x90] = 0x9
            set xorData[0x91] = 0x8
            set xorData[0x92] = 0xb
            set xorData[0x93] = 0xa
            set xorData[0x94] = 0xd
            set xorData[0x95] = 0xc
            set xorData[0x96] = 0xf
            set xorData[0x97] = 0xe
            set xorData[0x98] = 0x1
            set xorData[0x99] = 0x0
            set xorData[0x9a] = 0x3
            set xorData[0x9b] = 0x2
            set xorData[0x9c] = 0x5
            set xorData[0x9d] = 0x4
            set xorData[0x9e] = 0x7
            set xorData[0x9f] = 0x6
            set xorData[0xa0] = 0xa
            set xorData[0xa1] = 0xb
            set xorData[0xa2] = 0x8
            set xorData[0xa3] = 0x9
            set xorData[0xa4] = 0xe
            set xorData[0xa5] = 0xf
            set xorData[0xa6] = 0xc
            set xorData[0xa7] = 0xd
            set xorData[0xa8] = 0x2
            set xorData[0xa9] = 0x3
            set xorData[0xaa] = 0x0
            set xorData[0xab] = 0x1
            set xorData[0xac] = 0x6
            set xorData[0xad] = 0x7
            set xorData[0xae] = 0x4
            set xorData[0xaf] = 0x5
            set xorData[0xb0] = 0xb
            set xorData[0xb1] = 0xa
            set xorData[0xb2] = 0x9
            set xorData[0xb3] = 0x8
            set xorData[0xb4] = 0xf
            set xorData[0xb5] = 0xe
            set xorData[0xb6] = 0xd
            set xorData[0xb7] = 0xc
            set xorData[0xb8] = 0x3
            set xorData[0xb9] = 0x2
            set xorData[0xba] = 0x1
            set xorData[0xbb] = 0x0
            set xorData[0xbc] = 0x7
            set xorData[0xbd] = 0x6
            set xorData[0xbe] = 0x5
            set xorData[0xbf] = 0x4
            set xorData[0xc0] = 0xc
            set xorData[0xc1] = 0xd
            set xorData[0xc2] = 0xe
            set xorData[0xc3] = 0xf
            set xorData[0xc4] = 0x8
            set xorData[0xc5] = 0x9
            set xorData[0xc6] = 0xa
            set xorData[0xc7] = 0xb
            set xorData[0xc8] = 0x4
            set xorData[0xc9] = 0x5
            set xorData[0xca] = 0x6
            set xorData[0xcb] = 0x7
            set xorData[0xcc] = 0x0
            set xorData[0xcd] = 0x1
            set xorData[0xce] = 0x2
            set xorData[0xcf] = 0x3
            set xorData[0xd0] = 0xd
            set xorData[0xd1] = 0xc
            set xorData[0xd2] = 0xf
            set xorData[0xd3] = 0xe
            set xorData[0xd4] = 0x9
            set xorData[0xd5] = 0x8
            set xorData[0xd6] = 0xb
            set xorData[0xd7] = 0xa
            set xorData[0xd8] = 0x5
            set xorData[0xd9] = 0x4
            set xorData[0xda] = 0x7
            set xorData[0xdb] = 0x6
            set xorData[0xdc] = 0x1
            set xorData[0xdd] = 0x0
            set xorData[0xde] = 0x3
            set xorData[0xdf] = 0x2
            set xorData[0xe0] = 0xe
            set xorData[0xe1] = 0xf
            set xorData[0xe2] = 0xc
            set xorData[0xe3] = 0xd
            set xorData[0xe4] = 0xa
            set xorData[0xe5] = 0xb
            set xorData[0xe6] = 0x8
            set xorData[0xe7] = 0x9
            set xorData[0xe8] = 0x6
            set xorData[0xe9] = 0x7
            set xorData[0xea] = 0x4
            set xorData[0xeb] = 0x5
            set xorData[0xec] = 0x2
            set xorData[0xed] = 0x3
            set xorData[0xee] = 0x0
            set xorData[0xef] = 0x1
            set xorData[0xf0] = 0xf
            set xorData[0xf1] = 0xe
            set xorData[0xf2] = 0xd
            set xorData[0xf3] = 0xc
            set xorData[0xf4] = 0xb
            set xorData[0xf5] = 0xa
            set xorData[0xf6] = 0x9
            set xorData[0xf7] = 0x8
            set xorData[0xf8] = 0x7
            set xorData[0xf9] = 0x6
            set xorData[0xfa] = 0x5
            set xorData[0xfb] = 0x4
            set xorData[0xfc] = 0x3
            set xorData[0xfd] = 0x2
            set xorData[0xfe] = 0x1
            set xorData[0xff] = 0x0
        endmethod

        private static method onInit takes nothing returns nothing
            call initShiftData()
            call initANDData()
            call initORData()
            call initXORData()
        endmethod
    endmodule

endlibrary