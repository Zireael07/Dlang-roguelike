module source.ecs;

import std.stdio;

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

struct Name {
    string name;
}

struct NPC {}

struct Stats {
    int hp;
    int max_hp;
    int power;
    this(int life, int pow){
        this.hp = life;
        this.max_hp = life;
        this.power = pow;
        //writeln("HP: ", this.hp, this.max_hp, "pow", this.power);
    }
}

// struct Combat {
//     int target_id;
// }

struct Components {
    bool pos;
    bool renderable; //=false
    bool tileblocker; //=false
    bool name;
    bool npc;
    bool stats;
    //bool combat;
    string toString() {
        import std.format: format;

        return "Components(pos: %s, render: %s, tileblocker: %s, name: %s, NPC: %s, stats: %s, combat: %s)".format(pos, renderable, tileblocker, name, npc, stats); //, combat);
    }
}

// 'World' in the ECS sense
struct World {
    //no dynamic arrays in BetterC, sadly
    //managers per type to work around trying to find a super-type for all structs
    Position[2048] PositionManager;
    Renderable[2048] RenderableManager;
    Name[2048] NameManager;
    NPC[2048] NPCManager;
    Stats[2048] StatsManager;
    //Combat[2048] CombatManager;

    //slices
    Position[] PositionManager_sl;
    Renderable[] RenderableManager_sl;
    Name[] NameManager_sl;
    NPC[] NPCManager_sl;
    Stats[] StatsManager_sl;
    
    //store whether we have the component
    Components[2048] comps; 
    Components[] sl; //slice
    //set us up
    void setup(){
        //0 is always the player
        Renderable rnd = Renderable('@');
        this.RenderableManager[0] = rnd;
        //centrally on map
        Position pos = Position(40,25);
        this.PositionManager[0] = pos;
        Stats pl_stats = Stats(20, 5);
        this.StatsManager[0] = pl_stats;
        Components comp = Components(true, true);
        comp.stats = true;
        this.comps[0] = comp;
        

        rnd = Renderable('h');
        this.RenderableManager[1] = rnd;
        pos = Position(4,4);
        this.PositionManager[1] = pos;
        Name nm = Name("Thug");
        this.NameManager[1] = nm;
        NPC npc = NPC();
        this.NPCManager[1] = npc;
        Stats stat = Stats(10, 2);
        this.StatsManager[1] = stat;
        comp = Components(true, true, true, true, true, true);
        this.comps[1] = comp;

        //slice
        auto sl = this.comps[0..2]; //get all components for existing entities
        this.sl = sl;
        //slices to all the managers in order to be able to remove
        auto RenderableManager_sl = this.RenderableManager[0..2];
        auto PositionManager_sl = this.PositionManager[0..2];
        auto NameManager_sl = this.NameManager[0..2];
        auto NPCManager_sl = this.NPCManager[0..2];
        auto StatsManager_sl = this.StatsManager[0..2];
        this.RenderableManager_sl = RenderableManager_sl;
        this.PositionManager_sl = PositionManager_sl;
        this.NameManager_sl = NameManager_sl;
        this.NPCManager_sl = NPCManager_sl;
        this.StatsManager_sl = StatsManager_sl;
    }

    void remove(int id){
        writeln("Removing entity of id ", id);
        writeln("Slice ", this.sl.length);
        //special case
        if (id == 1){
            //update manager slices
            //'$' is a shortcut to array.length
            this.RenderableManager_sl = this.RenderableManager_sl[0..1];
            this.PositionManager_sl = this.PositionManager_sl[0..1];
            this.NameManager_sl = this.NameManager_sl[0..1];
            this.NPCManager_sl = this.NPCManager_sl[0..1];
            this.StatsManager_sl = this.StatsManager_sl[0..1];
            //this.comps = this.comps[0..$-1];
            //update slice
            auto sl = this.comps[0..1];
            this.sl = sl;
            writeln("Slice after remove: ", this.sl.length);
        }

        else if (id == this.sl.length-1){
            //update manager slices
            //'$' is a shortcut to array.length
            this.RenderableManager_sl = this.RenderableManager_sl[0..$-1];
            this.PositionManager_sl = this.PositionManager_sl[0..$-1];
            this.NameManager_sl = this.NameManager_sl[0..$-1];
            this.NPCManager_sl = this.NPCManager_sl[0..$-1];
            this.StatsManager_sl = this.StatsManager_sl[0..$-1];
            //this.comps = this.comps[0..$-1];
            //update slice
            auto sl = this.comps[0..$-1];
            this.sl = sl;
            writeln("Slice after remove: ", this.sl.length);
        }
        else {
            //TODO for removing entities not from end of slice
        }

    }

}