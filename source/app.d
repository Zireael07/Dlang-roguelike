module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;
import std.stdio;

import source.map;
import source.fov;
//import source.astar;
import source.pathfinding;
import source.ecs;


class Engine {
    Map map;
    ShadowCastFOV fov;
    //BFS pathing;
    Dijkstra pathing;
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

    bool PlayerMove(int dx, int dy){
        int tx = this.world.PositionManager[0].x + dx;
        int ty = this.world.PositionManager[0].y + dy;

        //don't walk out of map
        if (tx < 0 || tx > this.map.width-1 || ty < 0 || ty > this.map.height-1){
            return false;
        }

        //check for unwalkable tiles
        if (this.map.isWall(tx, ty)){
            return false;
        }

        //check for entities
        if (this.getTileBlockers(tx, ty)){
            //combat goes here;
            return false;
        }

        this.world.PositionManager[0].x = tx;
        this.world.PositionManager[0].y = ty;
        onPlayerMove();
        return true;
    }

    void onPlayerMove(){
        foreach (i, c; this.world.sl){ //this.comps
            if (c.npc & c.name){
                takeTurn(i);
               //debug
               //writeln(this.world.NameManager[i].name, " growls!");
           }
        }
    }

    // 'id' is the NPC's id (=index in managers)
    void takeTurn(ulong id) {
        //our position
        Point s = Point(this.world.PositionManager[id].x, this.world.PositionManager[id].y);
        //writeln("Start pt @: ", s.x, ", ", s.y);
        //player pos
        Point e = Point(this.world.PositionManager[0].x, this.world.PositionManager[0].y);

        //if( this.as.search( s, e, this.fov.map ) ) {
        //if ( this.pathing.path(s, e, this.fov.map)) {
            Point[] path;
            path = this.pathing.path(s, e, this.fov.map);
            // 'c' is cost
            //int c = as.path( path );
            //writeln(c, ", len: ", path.length );
            if (path.length > 0){
                // #0 is our own position
                if (path[1] != e){
                    //prevent weirdness
                    //if (abs(path[1].x - s.x) < 2 && abs(path[1].y - s.y) < 2){
                        //just move (the path only works on walkable tiles anyway)
                        this.world.PositionManager[id].x = path[1].x;
                        this.world.PositionManager[id].y = path[1].y;
                    //} 
                }
                else{
                    writeln("AI kicks at your shins");
                }
            }

            //debug
            // foreach( i; path ) {
            //     write("(", i.x, ", ", i.y, ") ");
            //  }
        //}
    }

    void update(){
       auto k = TCOD_console_check_for_keypress(TCOD_KEY_PRESSED);
        switch(k.vk) {
            case TCODK_UP : 
                this.PlayerMove(0, -1);
            break;
            case TCODK_DOWN : 
                this.PlayerMove(0,1);
            break;
            case TCODK_LEFT : 
                this.PlayerMove(-1,0);
            break;
            case TCODK_RIGHT :
                this.PlayerMove(1,0);
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

 
