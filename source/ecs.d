module source.ecs;

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

struct Components {
    bool pos;
    bool renderable; //=false
    bool tileblocker; //=false
    bool name;
    bool npc;
    string toString() {
        import std.format: format;

        return "Components(pos: %s, render: %s, tileblocker: %s, name: %s, NPC: %s)".format(pos, renderable, tileblocker, name, npc);
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
        Components comp = Components(true, true);
        this.comps[0] = comp;

        rnd = Renderable('h');
        this.RenderableManager[1] = rnd;
        pos = Position(4,4);
        this.PositionManager[1] = pos;
        Name nm = Name("Thug");
        this.NameManager[1] = nm;
        NPC npc = NPC();
        this.NPCManager[1] = npc;
        comp = Components(true, true, true, true, true);
        this.comps[1] = comp;

        //slice
        auto sl = this.comps[0..2]; //get all components for existing entities
        this.sl = sl;
    }
}