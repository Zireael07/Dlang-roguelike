module source.map;

import tcod.c.all; //for the render function

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