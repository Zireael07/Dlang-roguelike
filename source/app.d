module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;


struct Tile {
    //default value
    bool can_walk = true;
}

class Map {
   int width,height;
   protected Tile[] tiles;

   //constructor
   this(int width, int height){
       this.width = width;
       this.height = height;
       this.tiles=new Tile[width*height];

       //mapgen
       setWall(30,22);
       setWall(50,22);
   }

   bool isWall(int x, int y){
       //2d map to 1D array
       return !tiles[x+y*this.width].can_walk;
   }
   void render() {
        foreach( y; 0 .. this.height )
        {
            foreach( x; 0 .. this.width )
            {
                if (isWall(x,y)) {
                    TCOD_console_put_char(null, x, y, '#', TCOD_BKGND_NONE);
                }
                else{
                    TCOD_console_put_char(null, x, y, '.', TCOD_BKGND_NONE);
                }
            }
        }
   }

   void setWall(int x, int y){
       tiles[x+y*width].can_walk=false;
   }
};


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
                if (!this.map.isWall(this.playerx, this.playery-1) && this.playery > 1){
                    this.playery--; 
                }
            break;
            case TCODK_DOWN : 
                if (!this.map.isWall(this.playerx, this.playery+1) && this.playery < this.map.height-2){
                    this.playery++; 
                }    
            break;
            case TCODK_LEFT : 
                if (!this.map.isWall(this.playerx-1, this.playery) && this.playerx > 0){
                    this.playerx--; 
                }
            break;
            case TCODK_RIGHT :
                if (!this.map.isWall(this.playerx+1, this.playery) && this.playerx < this.map.width-1){
                    this.playerx++; 
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

 
