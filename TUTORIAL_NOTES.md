Part 0

The biggest problem, as in most C-family projects, is to get the project to find the external library used. Libtcod has D bindings and they come with an example project - I just copied their file layout.

Part 2

The biggest departure from the tutorial is my poor (wo)man's attempt at an ECS from scratch. The idea to have a manager per component I got from some ECS design article I can't remember (TODO: put a link if/when I find it). Slices are there to allow us to delete entities, as arrays are static.

Part 3

Simplest possible map (just an arena with two pillars) because the map is not our focus, getting this off the ground - and learning D - is!

Part 4

Fairly straightforward adaptation of Bjorn Bergstroem's recursive shadowcasting FOV.

Part 6

The original tutorial uses very dumb AI that only relies on vector towards the player to move. That's too dumb for even a sample game, so we need some pathfinding. I ended up implementing all three varieties in order (BFS, Dijkstra, A*) based on Amit's excellent tutorial on RedBlobGames.
Getting the entities to 'die' (be removed from slices) was a bit of a challenge, too.

Part 7

A straightforward port of the tutorial, minus some gfx bells and whistles I didn't care about.

Part 8

I couldn't find the equivalent of waitForEvent() in the D bindings, so I ended up just adding a flag to the engine that tells us when we're in inventory mode. Effectively it's the same, and also it lends itself better to a possible WASM sequel.

Part 9

Instead of implementing three scrolls, I just implemented one (a magic missile that hits an actor). The target selection function, this time, is a direct port of the one from the c++ tutorial.

Part 10

We ended up mixing approaches. Serializing is handled by an existing library but deserializing from JSON had to be handled by hand.