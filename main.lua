tilecollider = require 'tilecollider'
-------------------------------------------------------------------------------

-- create player
p1  = {x = 64,y = 64, w = 32, h = 32}

function p1:unpack()
	return self.x,self.y,self.w,self.h
end

function p1:draw()
	love.graphics.rectangle('line',self:unpack())
end

-------------------------------------------------------------------------------

-- our map
grid = 
	{
		tileWidth   = 64,
		tileHeight  = 64,
		{2,2,2,2,2,2,2,2, 2 ,2,2,2},
		{2,1,1,1,1,1,1,1,'g',1,1,2},
		{2,1,1,1,1,1,1,1,'g',1,1,2},
		{2,1,1,1,1,4,2,1,'g',1,1,2},
		{2,1,1,1,1,2,2,2, 2 ,1,1,2},
		{2,1,1,1,1,1,1,1,'b',1,1,2},
		{2,1,3,2,1,1,1,1,'b',1,1,2},
		{2,2,2,2,2,2,2,2, 2 ,2,2,2},
	}

-- some information about each tile
tileset = 
{
	[1] =
	{
		color = {255,255,255},
		type  = 1,
	},
	[2] =
	{
		color = {255,0,0},
		type  = 2,
	},
	g =
	{
		color = {0,255,0},
		type  = 3,
	},
	b =
	{
		color = {0,0,255},
		type  = 4,
	},
	-- vertical slope tile
	[3] =
	{
		color = {0,255,255},
		type  = 'vert',
	},
	-- horizontal slope tile
	[4] =
	{
		color = {255,100,0},
		type  = 'horz',
	},
}

-------------------------------------------------------------------------------

-- lookup table for slope tiles
heightmaps    = {}
heightmaps[3] = {vertical   = (function() local t = {} for i = 1,64 do t[i] = i end return t end)()}
heightmaps[4] = {horizontal = (function() local t = {} for i = 1,64 do t[i] = i end return t end)()}

-- callback for handler to get tile
function getTile(tx,ty)
	return grid[ty][tx]
end

-- collision callback for handler
function isResolvable(side,tile,gx,gy)
	local tileData = tileset[tile]
	local tileType = tileData.type

	if tileType == 2 then return true end
	
	if tileType == 'vert' and side == 'bottom' then return true end
	
	if tileType == 'horz' and side == 'right' then return true end
	
	-- one way tile
	if tileType == 3 then 
		if side == 'left' and prevLeftGX > gx then return true end
	end
	
	-- one way tile
	if tileType == 4 then 
		if side == 'right' and prevRightGX < gx then return true end
	end
end

-------------------------------------------------------------------------------

-- tile collision handler
handler = tilecollider(getTile, grid.tileWidth,grid.tileHeight, isResolvable,heightmaps)

-------------------------------------------------------------------------------

-- for one way tiles (see below)
function getTileRange(tw,th,x,y,w,h)
	gx,gy   = math.floor(x/tw)+1,math.floor(y/th)+1
	gx2,gy2 = math.ceil( (x+w)/tw ),math.ceil( (y+h)/th )
	return gx,gy,gx2,gy2
end

velocity = 400

function love.update(dt)
	if love.keyboard.isDown('left') then
		dx = -velocity*dt
	elseif love.keyboard.isDown('right') then
		dx = velocity*dt
	else 
		dx = 0
	end
	if love.keyboard.isDown('up') then
		dy = -velocity*dt
	elseif love.keyboard.isDown('down') then
		dy = velocity*dt
	else
		dy = 0
	end
	
	prevLeftGX,_,prevRightGX = getTileRange(grid.tileWidth,grid.tileHeight,p1:unpack())
	
	-- move and resolve collisions
	p1.x = p1.x+dx
	if dx > 0 then
		newx = handler:rightResolve(p1:unpack())
	elseif dx < 0 then
		newx = handler:leftResolve(p1:unpack())
	else
		newx = handler:rightResolve(p1:unpack())
		if newx == p1.x then newx = handler:leftResolve(p1:unpack()) end
	end
	
	p1.x = newx
	
	p1.y = p1.y+dy
	
	if dy > 0 then
		newy = handler:bottomResolve(p1:unpack())
	elseif dy < 0 then
		newy = handler:topResolve(p1:unpack())
	else
		newy = handler:bottomResolve(p1:unpack())
		if newy == p1.y then newy = handler:topResolve(p1:unpack()) end
	end
	
	p1.y = newy
end
-------------------------------------------------------------------------------
function love.draw()
	local tw,th = grid.tileWidth,grid.tileHeight
	for ty,t in ipairs(grid) do
		ty = ty-1
		for tx,tile in ipairs(t) do
				tx = tx-1
				love.graphics.setColor(tileset[tile].color)
				if tile == 3 or tile == 4 then
					-- draw slopes
					love.graphics.polygon('line',tx*tw,(ty+1)*th,(tx+1)*tw,(ty+1)*th,(tx+1)*tw,(ty*th))
				else
					-- draw regular blocks
					love.graphics.rectangle('line',tx*tw,ty*th,tw,th)
				end
		end
	end
	p1:draw('fill')
end