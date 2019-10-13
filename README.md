# Oh My Blob!

_Oh My Blob!_ is a turn-based puzzle action game for PICO-8. You can play it at
[iaoth.itch.io/ohmyblob](https://iaoth.itch.io/ohmyblob).

The code is divided into different files. There's the event system, the blob
logic, graphics, utils, titlescreen and the main lua file, and the two P8 carts
that contain graphics and music.

* eventsystem.lua contains code to "fire and forget" coroutines for taking care
of animations and logic.

* bloblogic.lua contains coroutines and definitions for how blobs act and move.

* graphics.lua has functions for drawing objects and the map etc.

* utils.lua has some small useful functions.

* titlescreen.lua contains logic and animations for the title screen and menu.

* main.lua has the bulk of code that ties everything together.

* omb.p8 is the main PICO-8 cart.

* gameover.p8 contains the victory screen.
