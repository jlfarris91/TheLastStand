library GameConstants

globals
    constant real TIME_OF_DAY = 6.00
    constant real TIME_OF_NIGHT = 18.00
    constant real GAME_SPEED_DAY = 80.0
    constant real GAME_SPEED_NIGHT = 120.0
    constant real PI = 3.14159265359

    constant integer ID_HERO = 'H002'
    constant integer ID_UNRESCUED_SURVIVOR = 'h00Z'
    constant integer ID_WANDERING_ZOMBIE = 'n000'
    constant integer ID_ZOMBIE = 'n001'

    player g_UndeadPlayer = Player(8)
    player g_VillagersPlayer = Player(9)
    player g_RaidersPlayer = Player(10)
endglobals

endlibrary