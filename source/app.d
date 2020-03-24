module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;

void main()
{
    //set font
    string font = "data/fonts/consolas10x10_gs_tc.png";
    int font_flags = TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_TCOD;
    //int font_new_flags = 0;
    int nb_char_horiz = 0, nb_char_vertic = 0;
    TCOD_console_set_custom_font(toStringz(font), font_flags, nb_char_horiz, nb_char_vertic);
    
    //centrally on map
    int playerx=40,playery=25;

    //hello world
    TCOD_console_init_root(80, 50, "Hello, world.", false, TCOD_RENDERER_SDL);

    //Game loop
    //1. input
    //2. draw
    while(!TCOD_console_is_window_closed()) {
        auto k = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        switch(k.vk) {
            case TCODK_UP : 
                playery--; 
                break;
            case TCODK_DOWN : 
                playery++; 
                break;
            case TCODK_LEFT : 
                playerx--; 
                break;
            case TCODK_RIGHT :
                playerx++; 
                break;
            default:break;
       }

        
        TCOD_console_clear(null);
        TCOD_console_put_char(null, playerx, playery, '@', TCOD_BKGND_NONE);
        
        //TCOD_console_print(null, 0, 0, "Hello, world.");
        TCOD_console_flush();
        
    }
}

 
