module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;


import source.map;


class Engine {
    Map map;
    int playerx;
    int playery;
    //constructor
    this(){
        //centrally on map
        this.playerx=40;
        this.playery=25;
        //hello world
        TCOD_console_init_root(80, 50, "Hello, world.", false, TCOD_RENDERER_SDL);
        this.map = new Map(80,45);
    }

    void update(){
       auto k = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        switch(k.vk) {
            case TCODK_UP : 
                if (this.playery > 0){
                    if (!this.map.isWall(this.playerx, this.playery-1)){
                        this.playery--; 
                    }          
                }
            break;
            case TCODK_DOWN : 
                if (this.playery < this.map.height-1){
                    if (!this.map.isWall(this.playerx, this.playery+1)){
                        this.playery++; 
                    }
                }    
            break;
            case TCODK_LEFT : 
                if (this.playerx > 0){
                    if (!this.map.isWall(this.playerx-1, this.playery)){
                        this.playerx--; 
                    }
                }
            break;
            case TCODK_RIGHT :
                if (this.playerx < this.map.width-1){
                    if (!this.map.isWall(this.playerx+1, this.playery)){
                        this.playerx++; 
                    }
                }
            break;
            default:break;
       }
   }

   void render(){
        TCOD_console_clear(null);
        //draw map
        this.map.render();
        TCOD_console_put_char(null, playerx, playery, '@', TCOD_BKGND_NONE);
        
        //TCOD_console_print(null, 0, 0, "Hello, world.");

   }
}




void main()
{
    //set font
    string font = "data/fonts/consolas10x10_gs_tc.png";
    int font_flags = TCOD_FONT_TYPE_GREYSCALE | TCOD_FONT_LAYOUT_TCOD;
    //int font_new_flags = 0;
    int nb_char_horiz = 0, nb_char_vertic = 0;
    TCOD_console_set_custom_font(toStringz(font), font_flags, nb_char_horiz, nb_char_vertic);

    Engine engine = new Engine();

    
    //Game loop
    //1. input
    //2. draw
    while(!TCOD_console_is_window_closed()) {
        engine.update();
        engine.render();
        TCOD_console_flush();
        
    }
}

 
