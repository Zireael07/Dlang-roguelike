module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;
import std.stdio;

import source.map;
import source.fov;
import source.astar;
import source.ecs;


class Engine {
    Map map;
    ShadowCastFOV fov;
    AStar as;
    World world;
    

    //constructor
    this(){
        //hello world
        TCOD_console_init_root(80, 50, "Hello, world.", false, TCOD_RENDERER_SDL);
        this.map = new Map(80,45);
        this.fov = new ShadowCastFOV(this.map);

        //ECS
        this.world = World();
        this.world.setup();
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
        foreach (i, c; this.world.sl){ //this.comps
           if (c.pos && c.tileblocker){
               if (this.world.PositionManager[i].x == x && this.world.PositionManager[i].y == y){
                   ret = true;
                   break;
               }
           }
        }
        return ret;
    }

    void onPlayerMove(){
        foreach (i, c; this.world.sl){ //this.comps
            if (c.npc & c.name){
               //debug
               writeln(this.world.NameManager[i].name, " growls!");
           }
        }
    }

    void update(){
       auto k = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        switch(k.vk) {
            case TCODK_UP : 
                if (this.world.PositionManager[0].y > 0){
                    if (!this.map.isWall(this.world.PositionManager[0].x, this.world.PositionManager[0].y-1)){
                        if (!this.getTileBlockers(this.world.PositionManager[0].x, this.world.PositionManager[0].y-1)){
                            this.world.PositionManager[0].y--;
                            onPlayerMove();
                        }
                        
                    }          
                }
            break;
            case TCODK_DOWN : 
                if (this.world.PositionManager[0].y < this.map.height-1){
                    if (!this.map.isWall(this.world.PositionManager[0].x, this.world.PositionManager[0].y+1)){
                        if (!this.getTileBlockers(this.world.PositionManager[0].x, this.world.PositionManager[0].y+1)){
                            this.world.PositionManager[0].y++;
                            onPlayerMove();
                        }
                    }
                }    
            break;
            case TCODK_LEFT : 
                if (this.world.PositionManager[0].x > 0){
                    if (!this.map.isWall(this.world.PositionManager[0].x-1, this.world.PositionManager[0].y)){
                        if (!this.getTileBlockers(this.world.PositionManager[0].x-1, this.world.PositionManager[0].y)){
                            this.world.PositionManager[0].x--;
                            onPlayerMove();
                        }
                    }
                }
            break;
            case TCODK_RIGHT :
                if (this.world.PositionManager[0].x < this.map.width-1){
                    if (!this.map.isWall(this.world.PositionManager[0].x+1, this.world.PositionManager[0].y)){
                        if (!this.getTileBlockers(this.world.PositionManager[0].x+1, this.world.PositionManager[0].y)){
                            this.world.PositionManager[0].x++;
                            onPlayerMove();
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
        this.fov.computeFOV(this.world.PositionManager[0].x, this.world.PositionManager[0].y, 6); //6 tiles 5ft. each = 30 ft.

        //draw map
        this.render(this.fov);
        //this.map.render();
        //TCOD_console_put_char(null, playerx, playery, '@', TCOD_BKGND_NONE);

        //test ECS
        //writeln(this.comps[0].toString());

        //test Astar
        Point s = Point(this.world.PositionManager[0].x, this.world.PositionManager[0].y);
        //writeln("Start pt @: ", s.x, ", ", s.y);
        Point e = Point(6,6); //test
        if( this.as.search( s, e, this.fov.map ) ) {
            Point[] path;
            // 'c' is cost
            int c = as.path( path );
            //debug
            // foreach( i; path ) {
            //     writeln("(", i.x, ", ", i.y, ") ");
            //  }
         }

        //render all existing entities with both position and renderable
        foreach (i, c; this.world.sl){ //this.comps
            //debug
           //writeln(i, ": ", c.toString());
           if (c.pos && c.renderable){
               TCOD_console_put_char(null, this.world.PositionManager[i].x, this.world.PositionManager[i].y, this.world.RenderableManager[i].chr, TCOD_BKGND_NONE);
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

 
