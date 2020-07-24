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

struct Item {}

struct InBackpack {}

struct Heal {}

struct Components {
    bool pos;
    bool renderable; //=false
    bool tileblocker; //=false
    bool name;
    bool npc;
    bool stats;
    bool item;
    bool in_backpack;
    bool heal;
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
    Item[2048] ItemManager;
    InBackpack[2048] BackpackManager;
    Heal[2048] HealManager;

    //slices
    Position[] PositionManager_sl;
    Renderable[] RenderableManager_sl;
    Name[] NameManager_sl;
    NPC[] NPCManager_sl;
    Stats[] StatsManager_sl;
    Item[] ItemManager_sl;
    InBackpack[] BackpackManager_sl;
    Heal[] HealManager_sl;
    
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

        int next_ent = 1;
        //add an item
        rnd = Renderable('!');
        this.RenderableManager[next_ent] = rnd;
        pos = Position(10,10);
        this.PositionManager[next_ent] = pos;
        Name nm = Name("Potion");
        this.NameManager[next_ent] = nm;
        Item it = Item();
        this.ItemManager[next_ent] = it;
        Heal hl = Heal();
        this.HealManager[next_ent] = hl;
        comp = Components(true, true, false, true, false, false, true, false, true);
        this.comps[next_ent] = comp;
        next_ent++;

        rnd = Renderable('h');
        this.RenderableManager[next_ent] = rnd;
        pos = Position(4,4);
        this.PositionManager[next_ent] = pos;
        nm = Name("Thug");
        this.NameManager[next_ent] = nm;
        NPC npc = NPC();
        this.NPCManager[next_ent] = npc;
        Stats stat = Stats(10, 2);
        this.StatsManager[next_ent] = stat;
        comp = Components(true, true, true, true, true, true);
        this.comps[next_ent] = comp;
        next_ent++;
        

        //slice
        int max_num = 3;
        auto sl = this.comps[0..max_num]; //get all components for existing entities
        this.sl = sl;
        //slices to all the managers in order to be able to remove
        auto RenderableManager_sl = this.RenderableManager[0..max_num];
        auto PositionManager_sl = this.PositionManager[0..max_num];
        auto NameManager_sl = this.NameManager[0..max_num];
        auto NPCManager_sl = this.NPCManager[0..max_num];
        auto StatsManager_sl = this.StatsManager[0..max_num];
        auto ItemManager_sl = this.ItemManager[0..max_num];
        auto BackpackManager_sl = this.BackpackManager[0..max_num];
        auto HealManager_sl = this.HealManager[0..max_num];
        this.RenderableManager_sl = RenderableManager_sl;
        this.PositionManager_sl = PositionManager_sl;
        this.NameManager_sl = NameManager_sl;
        this.NPCManager_sl = NPCManager_sl;
        this.StatsManager_sl = StatsManager_sl;
        this.ItemManager_sl = ItemManager_sl;
        this.BackpackManager_sl = BackpackManager_sl;
        this.HealManager_sl = HealManager_sl;
    }

    void remove(int id){
        writeln("Removing entity of id ", id);
        writeln("Slice ", this.sl.length);
        //special case
        if (id == 1){
            ulong end = this.sl.length-1;
            //update manager slices
            //'$' is a shortcut to array.length
            this.RenderableManager_sl = this.RenderableManager_sl[0..end];
            this.PositionManager_sl = this.PositionManager_sl[0..end];
            this.NameManager_sl = this.NameManager_sl[0..end];
            this.NPCManager_sl = this.NPCManager_sl[0..end];
            this.StatsManager_sl = this.StatsManager_sl[0..end];
            //this.comps = this.comps[0..$-1];
            //update slice
            auto sl = this.comps[0..end];
            this.sl = sl;
            writeln("Slice after remove: ", this.sl.length);
        }

        else if (id == this.sl.length-1){
            ulong end = this.sl.length-1;
            //update manager slices
            //'$' is a shortcut to array.length
            this.RenderableManager_sl = this.RenderableManager_sl[0..end];
            this.PositionManager_sl = this.PositionManager_sl[0..end];
            this.NameManager_sl = this.NameManager_sl[0..end];
            this.NPCManager_sl = this.NPCManager_sl[0..end];
            this.StatsManager_sl = this.StatsManager_sl[0..end];
            //this.comps = this.comps[0..$-1];
            //update slice
            auto sl = this.comps[0..end];
            this.sl = sl;
            writeln("Slice after remove: ", this.sl.length);
        }
        else {
            //TODO for removing entities not from end of slice
        }

    }

    void addComp(int id) {
        //currently hardcoded
        InBackpack bp = InBackpack();
        this.BackpackManager[id] = bp;
        Components comp = Components(true, true, false, true, false, false, true, true, true);
        this.comps[id] = comp;
    }

    void removeComp(int id) {
        //this.BackpackManager[id] = null;
        Components comp = Components(true, true, false, true, false, false, true, false, true);
        this.comps[id] = comp;
    }
}