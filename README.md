# Oh My Blob!

_Oh My Blob!_ is a turn-based puzzle action game for PICO-8. You can play it at
[iaoth.itch.io/ohmyblob](https://iaoth.itch.io/ohmyblob).

The code is divided into Lua files and carts (p8). There's the event system, the blob
logic, graphics, utils, titlescreen and the main lua file, and the two carts
that contain graphics and music. There's also a self-playing trailer version of
the game that mostly reuses code but has its own cart and a Lua file containing the
self-playing logic.

* eventsystem.lua contains code to "fire and forget" coroutines for taking care
of animations and logic.

* bloblogic.lua contains coroutines and definitions for how blobs act and move.

* graphics.lua has functions for drawing objects and the map etc.

* utils.lua has some small useful functions.

* titlescreen.lua contains logic and animations for the title screen and menu.

* main.lua has the bulk of code that ties everything together.

* omb.p8 is the main PICO-8 cart.

* gameover.p8 contains the victory screen.

* trailer.lua and trailer.p8 has special levels and logic for the trailer
