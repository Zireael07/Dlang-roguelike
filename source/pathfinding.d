//based on Amit's guide https://www.redblobgames.com/pathfinding/a-star/implementation.html

//basic loop is:
// frontier = Queue()
// frontier.put(start )
// came_from = {}
// came_from[start] = None

// while not frontier.empty():
//    current = frontier.get()
//    for next in graph.neighbors(current):
//       if next not in came_from:
//          frontier.put(next)
//          came_from[next] = current



module source.pathfinding;

import std.range;
import std.algorithm;
import std.stdio;

//custom
import source.map;


struct Point {
    int x;
    int y;
    Point opBinary(string op = "+")(Point o) { return Point( o.x + x, o.y + y ); }
}

//workaround for lack of associative arrays in BetterC
// point is the key and came the value
struct CameFrom {
    Point point; //key
    Point came; //value
}

struct BFS {
    Map map;
    Point end;
    Point start;
    Point[8] neighbours = [Point(-1,-1), Point(1,-1), Point(-1,1), Point(1,1), Point(0,-1), Point(-1,0), Point(0,1), Point(1,0)];
    // Point[] frontier;
    // CameFrom[] came_from;
    Point[] curr_neighbors;

    //is the point on map?
    bool isValid(Point p) {
        return ( p.x > -1 && p.y > -1 && p.x < map.width-1 && p.y < map.height-1 );
    }

    Point[] getNeighbours(Point p){
        Point[] res;
        for( int x = 0; x < 8; ++x ) {
            Point neighbour = p + neighbours[x];
            if (isValid(neighbour) && !map.isWall(neighbour.x,neighbour.y)){
                //add to array
                res ~= neighbour;
            }
        }
        return res;
    }


    CameFrom[] search(){
        Point[] frontier;
        CameFrom[] came_from;
        writeln("Search for start: ", start, " end: ", end);
        frontier ~= start;

        //find path
        while (!frontier.empty()){
            Point current = frontier.front();
            //writeln("cur: ", current);
            //remove it from frontier
            frontier.popFront();
            //writeln("frontier: ", frontier);

            //early exit
            if (current == end){
                //writeln("Early exit: ", current);
                break;
            }

            curr_neighbors = getNeighbours(current);
            foreach (n; curr_neighbors){
                bool find = came_from.canFind!((a,b) => a.point == b)(n);
                if (!find){
                    frontier ~= n;
                    came_from ~= CameFrom(n, current);
                }
            }
        }

        return came_from;
    }

    //now reconstruct path from came_from
    Point[] pathFromCameFrom(CameFrom[] came_from) {
        Point current = end;
        Point[] path;
        while (current != start) {
            path ~= current;
            //totally unintuitively named, effectively find() from other languages
            auto i = came_from.countUntil!((a,b) => a.point == b)(current);
            if (i != -1){
                current = came_from[i].came;
            }
            // else{
            //     writeln("Couldn't find ", current);
            //     break;
            // }
        }

        path ~= start;
        //fix the ordering
        path.reverse();

        return path;
    }

    // 'ref' is basically equivalent to C++ pointer
    Point[] path(ref Point s, ref Point e, ref Map mp) {
        end = e; start = s; map = mp;
        //came_from = CameFrom[];
        //frontier = Point[];


        CameFrom[] camefrom = search();
        writeln("search length: ", camefrom.length);
        // foreach(i; points){
        //     write("(", i.came.x, ", ", i.came.y, ") ");
        // }

        Point[] path = pathFromCameFrom(camefrom);

        // foreach( i; path ) {
        //     write("(", i.x, ", ", i.y, ") ");
        // }

        return path;
    }

}


// struct AStar {
//     Map map;
//     Point end;
//     Point start;
//    	Point[8] neighbours = [Point(-1,-1), Point(1,-1), Point(-1,1), Point(1,1), Point(0,-1), Point(-1,0), Point(0,1), Point(1,0)];
//     Node[] open;
//     Node[] closed;
 
//     int calcDist(Point p) {
//         // diagonal movement - assumes diag dist is 1, same as cardinals
// 		return max(abs(p.x - end.x), abs(p.y - end.y));
//     }
 
//     //is the point on map?
//     bool isValid(Point p) {
//         return ( p.x > -1 && p.y > -1 && p.x < map.width-1 && p.y < map.height-1 );
//     }

//     Point[] neighbours(Point p){
//         Point[] res;
//         for( int x = 0; x < 8; ++x ) {
//             neighbour = p.pos + neighbours[x];
//             if (isValid(neighbour) && !map.isWall(neighbour.x,neighbour.y)){
//                 //add to array
//                 res ~= neighbour;
//             }
//         }
//         return res;
//     }
// }