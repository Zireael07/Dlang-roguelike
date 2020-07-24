module simple;

import tcod.c.all;
//to convert strings to 0-terminated as in C
import std.string;
import core.stdc.string;
import std.stdio : writeln, write;
import std.algorithm; //to remove from array

import source.map;
import source.fov;
import source.pathfinding;
import source.ecs;


struct Message{
    string text;
    TCOD_color_t color;
}

class Engine {
    Map map;
    ShadowCastFOV fov;
    //BFS pathing;
    //Dijkstra pathing;
    AStar pathing;
    World world;
    Message[] log;
    //flag for GUI
    bool showInv;

    //constructor
    this(){
        //hello world
        TCOD_console_init_root(80, 50, "Hello, world.", false, TCOD_RENDERER_SDL);
        this.map = new Map(80,40);
        this.fov = new ShadowCastFOV(this.map);

        //ECS
        this.world = World();
        this.world.setup();

        this.showInv = false;
    }

    void render(ShadowCastFOV fov) {
        foreach( y; 0 .. fov.map.height )
        {
            foreach( x; 0 .. fov.map.width )
            {
                if (fov.isVisible(x,y)) {
                    if (fov.map.isWall(x,y)) {
                        //'null' means default console, same applies to all the TCOD_console_* functions
                        TCOD_console_put_char(null, x, y, '#', TCOD_BKGND_NONE);
                    }
                    else{
                        TCOD_console_put_char(null, x, y, '.', TCOD_BKGND_NONE);
                    }
                }
                
            }
        }
    }

    void renderBar(int x, int y, int width, string name,
    float value, float maxValue, TCOD_color_t barColor, TCOD_color_t backColor){
        //'null' means the default console
        // fill the background
        TCOD_console_set_default_background(null, backColor);
        TCOD_console_rect(null, x,y,width,1,false,TCOD_BKGND_SET);
        //fill with color
        int barWidth = cast(int)(value / maxValue * width);
        if ( barWidth > 0 ) {
            // draw the bar
            TCOD_console_set_default_background(null, barColor);
            TCOD_console_rect(null, x,y,barWidth,1,false,TCOD_BKGND_SET);
        }
        // print text on top of the bar
        TCOD_console_set_default_foreground(null, TCOD_white);
        TCOD_console_print_ex(null, x+width/2,y,TCOD_BKGND_NONE,TCOD_CENTER,
       "%s : %g/%g", toStringz(name), value, maxValue);
       //reset bg color
       TCOD_console_set_default_background(null, TCOD_black);
    }

    void guiMessage(string msg){
        if (this.log.length == 6){
            this.log = this.log.remove(0);
        }
        //add to log
        this.log ~= Message(msg, TCOD_white);
    }

    int getTileBlockers(int x, int y){
        int ret = 0;
        foreach (i, c; this.world.sl){ //this.comps
           if (c.pos && c.tileblocker){
               if (this.world.PositionManager[i].x == x && this.world.PositionManager[i].y == y){
                   ret = (cast(int)(i));
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
        int blocking_id = this.getTileBlockers(tx, ty);
        if (this.getTileBlockers(tx, ty)){
            //combat goes here;
            int damage = this.world.StatsManager[0].power;
            this.world.StatsManager[blocking_id].hp -= damage;
            //concat a string works just like appending to an array
            this.guiMessage("Player dealt " ~ format("%d", damage) ~ " damage to enemy!");
            //dead
            if (this.world.StatsManager[blocking_id].hp <= 0){
                //writeln("Enemy dead!");
                this.guiMessage("Player killed enemy");
                //remove from ECS
                this.world.remove(blocking_id);
            }
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
                    //combat
                    int damage = this.world.StatsManager[id].power;
                    this.world.StatsManager[0].hp -= damage;
                    //concat a string works just like appending to an array
                    this.guiMessage("Enemy dealt " ~ format("%d", damage) ~ " damage to player!");
                    //writeln("Player hp: ", this.world.StatsManager[0].hp);
                    //dead
                    if (this.world.StatsManager[0].hp <= 0){
                        writeln("Player dead!");
                    }
                }
            }

            //debug
            // foreach( i; path ) {
            //     write("(", i.x, ", ", i.y, ") ");
            //  }
        //}
    }

    int GetItemAtPos(int x, int y) {
        int ret = 0;
        foreach (i, c; this.world.sl){
           if (c.pos && c.item && ! c.in_backpack){
               if (this.world.PositionManager[i].x == x && this.world.PositionManager[i].y == y){
                   ret = (cast(int)(i));
                   break;
               }
           }
        }
        return ret;
    }

    void GetItem() {
        int x = this.world.PositionManager[0].x;
        int y = this.world.PositionManager[0].y;

        int it = this.GetItemAtPos(x,y);
        if (it) {
            this.world.addComp(it);
            this.guiMessage("Picked up item");
        } 
        else {
            this.guiMessage("Nothing to pick up here!");
        }
    }

    void drawInventory() {
        // fill the background
        TCOD_console_set_default_background(null, TCOD_black);
        TCOD_console_rect(null, 5,5,20,10,false,TCOD_BKGND_SET);
        
        TCOD_console_set_default_foreground(null, TCOD_white);
        TCOD_console_print(null, 7, 6, toStringz("INVENTORY"));
        // display the items with their keyboard shortcut
        int shortcut='a';
        int y=8;

        foreach (i, c; this.world.sl){
           if (c.pos && c.item && c.in_backpack){
               TCOD_console_print(null, 5+2, y, "(%c) %s", shortcut, toStringz(this.world.NameManager[i].name));
               y++;
               shortcut++;
           }
        }

        //TCOD_console_flush();
    }

    void ShowInventory(){
        this.showInv = true;   
    }

    ulong[2048] getInventory(){
        ulong[2048] item_shortcuts;
        int shortcut='a';
        //writeln("Shortcut ", shortcut);

        foreach (i, c; this.world.sl){
           if (c.pos && c.item && c.in_backpack){
               item_shortcuts[shortcut] = i;
               writeln("Shorcut ", shortcut, " set to ", i);
               shortcut++;
               
           }
        }

        return item_shortcuts;
    }

    void UseItem(int index) {
        //writeln("Using item with index ", index);
        if (index >=0 && index < 2){
            //is there an inventory item at index?
            ulong[2048] inv = this.getInventory();
            int shortcut = index + 'a';

            if (inv[shortcut] != 0) {
                this.guiMessage("Using " ~ format("%s", this.world.NameManager[inv[shortcut]].name));
                //is this a heal item?
                if (this.world.sl[inv[shortcut]].heal){
                    //heal
                    int heal = 5;
                    if (this.world.StatsManager[0].hp > this.world.StatsManager[0].max_hp-5) {
                        heal = this.world.StatsManager[0].max_hp - this.world.StatsManager[0].hp;
                    }
                    this.world.StatsManager[0].hp += heal;
                    this.guiMessage("Healed 5 hp!");
                    //axe the potion
                    this.world.remove(cast(int)inv[shortcut]);
                }
            }
        }
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
            //any printable (ASCII) key
            case TCODK_CHAR :
                //check key char now
                auto c = k.c;
                    //inventory
                    if (this.showInv) {
                        int actorIndex = k.c - 'a';
                        this.UseItem(actorIndex);
                        this.showInv = false;
                    }
                    else {
                        switch (k.c) {
                            case 'g' :
                                this.GetItem();
                            break;
                            case 'i' :
                                //toggle inventory
                                if (!this.showInv){
                                    this.ShowInventory();
                                }
                                // else {
                                //     this.showInv = false;
                                // }
                                
                            break;
                            default:break;
                        }

                    } 
                //}
                
            break;
            case TCODK_ESCAPE :
                //exit inventory
                if (this.showInv){
                    this.showInv = false;
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
        //draw gui
        // draw the health bar
        this.renderBar(1,43,20,"HP",this.world.StatsManager[0].hp, this.world.StatsManager[0].max_hp, TCOD_light_red, TCOD_darker_red);
        // draw the message log
        int y = 44;
        foreach (m; this.log){
            TCOD_console_print(null, 1, y, toStringz(m.text));
            y++;
        }

        //test ECS
        //writeln(this.comps[0].toString());


        //render all existing entities with both position and renderable
        foreach (i, c; this.world.sl){ //this.comps
            //debug
           //writeln(i, ": ", c.toString());
           if (c.pos && c.renderable && !c.in_backpack){
               TCOD_console_put_char(null, this.world.PositionManager[i].x, this.world.PositionManager[i].y, this.world.RenderableManager[i].chr, TCOD_BKGND_NONE);
           }
        } 


        //TCOD_console_print(null, 0, 0, "Hello, world.");

        //draw inventory
        if (this.showInv){
            this.drawInventory();
        }

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

 
