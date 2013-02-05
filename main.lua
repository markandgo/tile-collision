-- modification of https://github.com/markandgo/AT-Collider
entity = require 'tilecollider'
-------------------------------------------------------------------------------
-- required grid format
grid = 
	{
		tileWidth   = 64,
		tileHeight  = 64,
		{2,2,2,2,2,2,2,2, 2 ,2,2,2},
		{2,1,1,1,1,1,1,1,'g',1,1,2},
		{2,1,1,1,1,1,1,1,'g',1,1,2},
		{2,1,1,1,1,1,1,1,'g',1,1,2},
		{2,1,1,1,1,2,2,2, 2 ,1,1,2},
		{2,1,1,1,1,1,1,1,'b',1,1,2},
		{2,1,1,1,1,1,1,1,'b',1,1,2},
		{2,2,2,2,2,2,2,2, 2 ,2,2,2},
	}

-- properties for isResolvable callback
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
	-- how a slope tile would look like:
	slope =
	{
		color = {0,255,255},
		type  = 5,
		-- height arrays
		verticalHeightMap   = nil,
		horizontalHeightMap = nil,
	},
}
-------------------------------------------------------------------------------
p1 = entity.new(64,64,32,32,grid,tileset)

-- custom collision callback
function p1:isResolvable(side,tile,gx,gy)
	local tileType = tile.type

	if tileType == 2 then return true end
	
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
velocity = 400

function love.update(dt)
	if dt > 1/30 then dt = 1/30 end
	
	-- movement for p1
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
	
	prevLeftGX,_,prevRightGX = p1:getTileRange(p1.x,p1.y,p1.w,p1.h)
	
	-- move and resolve collisions
	p1:move(dx,dy)
end
-------------------------------------------------------------------------------
function love.draw()
	local tw,th = grid.tileWidth,grid.tileHeight
	for ty,t in ipairs(grid) do
		ty = ty-1
		for tx,tileID in ipairs(t) do
			tx = tx-1
			love.graphics.setColor(tileset[tileID].color)
			love.graphics.rectangle('line',tx*tw,ty*th,tw,th)
		end
	end
	p1:draw('fill')
end