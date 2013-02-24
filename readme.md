A modification of https://github.com/markandgo/AT-Collider without the ATL requirement.
It accepts a generic grid structure with complementary tileset.

## Height Maps

Vertical and horizontal height maps are supported for slopes. Just define an array ( `verticalHeightMap` or `horizontalHeightMap` ) of height values for each tile. For an object's position, vertical height maps adjust it vertically, while horizontal height maps adjust it horizontally. A tile can have both height maps at the same time. The following ASCII art shows the "shape" of a slope depending on which side touches it.

````
ASCII ART EXAMPLE
=================
4x4 tile example

tileset[tileID].verticalHeightMap = {1,2,3,4}

**Vertical Height Map**

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

tileset[tileID].horizontalHeightMap = {1,2,3,4}

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