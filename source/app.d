module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;
import std.stdio;

import source.map;
import source.fov;

//ECS components
struct Renderable{
    char chr;
    int id = 1;
}

struct Position {
    int x;
    int y;
    int id = 2;
}

struct TileBlocker {
    bool block = true;
}


struct Components {
    bool pos;
    bool renderable; //=false
    bool tileblocker; //=false
    string toString() {
        import std.format: format;

        return "Components(pos: %s, render: %s, tileblocker: %s)".format(pos, renderable, tileblocker);
    }
}

class Engine {
    Map map;
    ShadowCastFOV fov;

    //test ECS
    //no dynamic arrays in BetterC, sadly
    //managers per type to work around trying to find a super-type for all structs
    Position[2048] PositionManager;
    Renderable[2048] RenderableManager;
    
    //store whether we have the component
    Components[2048] comps; 
    Components[] sl; //slice

    //constructor
    this(){
        //hello world
        TCOD_console_init_root(80, 50, "Hello, world.", false, TCOD_RENDERER_SDL);
        this.map = new Map(80,45);
        this.fov = new ShadowCastFOV(this.map);

        //ECS
        //0 is always the player
        Renderable rnd = Renderable('@');
        this.RenderableManager[0] = rnd;
        //centrally on map
        Position pos = Position(40,25);
        this.PositionManager[0] = pos;
        Components comp = Components(true, true);
        this.comps[0] = comp;

        rnd = Renderable('h');
        this.RenderableManager[1] = rnd;
        pos = Position(4,4);
        this.PositionManager[1] = pos;
        comp = Components(true, true, true);
        this.comps[1] = comp;

        //slice
        auto sl = this.comps[0..2]; //get all components for existing entities
        this.sl = sl;
    }

    void render(ShadowCastFOV fov) {
        foreach( y; 0 .. fov.map.height )
        {
            foreach( x; 0 .. fov.map.width )
            {
                if (fov.isVisible(x,y)) {
                    if (fov.map.isWall(x,y)) {
                        TCOD_console_put_char(null, x, y, '#', TCOD_BKGND_NONE);
                    }
                    else{
                        TCOD_console_put_char(null, x, y, '.', TCOD_BKGND_NONE);
                    }
                }
                
            }
        }
   }

    bool getTileBlockers(int x, int y){
        bool ret = false;
        foreach (i, c; this.sl){ //this.comps
           if (c.pos && c.tileblocker){
               if (this.PositionManager[i].x == x && this.PositionManager[i].y == y){
                   ret = true;
                   break;
               }
           }
        }
        return ret;
    }

    void update(){
       auto k = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        switch(k.vk) {
            case TCODK_UP : 
                if (this.PositionManager[0].y > 0){
                    if (!this.map.isWall(this.PositionManager[0].x, this.PositionManager[0].y-1)){
                        if (!this.getTileBlockers(this.PositionManager[0].x, this.PositionManager[0].y-1)){
                            this.PositionManager[0].y--; 
                        }
                        
                    }          
                }
            break;
            case TCODK_DOWN : 
                if (this.PositionManager[0].y < this.map.height-1){
                    if (!this.map.isWall(this.PositionManager[0].x, this.PositionManager[0].y+1)){
                        if (!this.getTileBlockers(this.PositionManager[0].x, this.PositionManager[0].y+1)){
                            this.PositionManager[0].y++; 
                        }
                    }
                }    
            break;
            case TCODK_LEFT : 
                if (this.PositionManager[0].x > 0){
                    if (!this.map.isWall(this.PositionManager[0].x-1, this.PositionManager[0].y)){
                        if (!this.getTileBlockers(this.PositionManager[0].x-1, this.PositionManager[0].y)){
                            this.PositionManager[0].x--;
                        }
                    }
                }
            break;
            case TCODK_RIGHT :
                if (this.PositionManager[0].x < this.map.width-1){
                    if (!this.map.isWall(this.PositionManager[0].x+1, this.PositionManager[0].y)){
                        if (!this.getTileBlockers(this.PositionManager[0].x+1, this.PositionManager[0].y)){
                            this.PositionManager[0].x++;
                        }
                    }
                }
            break;
            default:break;
       }
   }

   void render(){
        TCOD_console_clear(null);

        //test FOV
        this.fov.clearFOV();
        this.fov.computeFOV(this.PositionManager[0].x, this.PositionManager[0].y, 6); //6 tiles 5ft. each = 30 ft.

        //draw map
        this.render(this.fov);
        //this.map.render();
        //TCOD_console_put_char(null, playerx, playery, '@', TCOD_BKGND_NONE);

        //test ECS
        //writeln(this.comps[0].toString());

        //render all existing entities with both position and renderable
        foreach (i, c; this.sl){ //this.comps
            //debug
           //writeln(i, ": ", c.toString());
           if (c.pos && c.renderable){
               TCOD_console_put_char(null, this.PositionManager[i].x, this.PositionManager[i].y, this.RenderableManager[i].chr, TCOD_BKGND_NONE);
           }
        } 


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

 
