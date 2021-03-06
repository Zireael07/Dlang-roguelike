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
       
       //walls around
       foreach( y; 0 .. this.height )
        {
            setWall(0, y);
            setWall(this.width-1, y);
        }

        foreach( x; 0 .. this.width )
        {
            setWall(x, 0);
            setWall(x, this.height-1);
        }
   }

   bool isWall(int x, int y){
       //2d map to 1D array
       return !tiles[x+y*this.width].can_walk;
   }

   void setWall(int x, int y){
       tiles[x+y*width].can_walk=false;
   }
};