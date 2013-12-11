Introduction
============

This is a module for handling collision with tile maps. It's
very simple to use. Set up callbacks and create a handler 
object, which is used to resolve collision with a tile map.

Usage
=====

Load the module:

	tilecollider = require 'tilecollider'

Create a new collision handler:
	
	handler = tilecollider(g,tw,th,c,h,s)
	
		g  - callback for tile lookup
		tw - width of a tile
		th - height of a tile
		c  - tile collision callback 
		h  - table of heightmaps for slope tiles
		s  - true if the top left of tile (0,0) is the origin [default]
		   - false if the top left of tile (1,1) is the origin
		
The handler has methods for resolving collision with a 
particular side. All tiles touching the area of a box 
are checked. After collision resolution, the functions 
return the new/old position.
	
	x = handler:leftResolve  (x,y,w,h)
	x = handler:rightResolve (x,y,w,h)
	y = handler:bottomResolve(x,y,w,h)
	y = handler:topResolve   (x,y,w,h)

Note: +x is to the right, +y is to the bottom

	x - coordinate of left side of box
	y - coordinate of top side of box
	w - width of the box
	h - height of the box
	
The following table describes which direction the box is
pushed to resolve a side collision.

	side     push
	----     ----
	
	left     right
	right    left
	bottom   up
	top      down
	
Callbacks
=========

The tile lookup function is used to retrieve the tile. The tile
is then passed to the collision callback for collision checking.
The collision callback must return true for the collision to be
resolved.

	tile = g(x,y)            - get the tile at specified coords 	
	bool = c(side,tile,x,y)  - pass info to collision callback

Heightmaps (OPTIONAL)
==========
	
Heightmaps are used for slope tiles. A slope collision is
resolved by looking up height values in an array. The height
values form the shape of the slope. A heightmap can be 
horizontal or vertical. A slope tile can have one or both.
Horizontal heightmaps only resolve collisions with the left 
and right sides. Vertical heightmaps only resolve collisions 
with the bottom and top sides. A table of heightmaps is used 
to index the heightmaps of a tile. See below for the format.

	format
	------
	
	h = 
	{
		[tile]  = 
		{
			vertical   = {...},
			horizontal = {...},
		},
		
		[tile2] = ...
	}
	
	heightmap type         compatible sides
	--------------         ----------------
	
	vertical               top  & bottom
	horizontal             left & right
	
````
ASCII ART EXAMPLE
=================
4x4 tile example

**Vertical Height Map**

vertical = {1,2,3,4}

"bottom"
4       |
3     | |
2   | | |
1 | | | |
  1 2 3 4

"top"
1 | | | |
2   | | |
3     | |
4       |
  1 2 3 4

**Horizontal Height Map**

horizontal = {1,2,3,4}

"left"
1 =
2 = =
3 = = =
4 = = = =
  1 2 3 4

"right"
1       =
2     = =
3   = = =
4 = = = =
  4 3 2 1
````
