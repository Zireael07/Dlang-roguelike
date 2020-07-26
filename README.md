This is an adaptation of the C++ Roguebasin tutorial to D aka Dlang. 

It is intentionally limited in the sense that's it's supposed to run in betterC mode https://dlang.org/spec/betterc.html, which means, among other things, no associative arrays (D's built-in hashmaps) or dynamic arrays. Only slices are allowed.
Libtcod is only used for input/output, as I originally planned to take this further into WASM land, which means as little reliance on libtcod as possible.

See TUTORIAL_NOTES.md for info pertaining to adaptations.
