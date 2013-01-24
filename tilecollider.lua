-- Tile Collider 1.0
local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-----------------------------------------------------------
-- class
local e   = 
	{
	class    = 'collider',
	isActive = true,
	isBullet = false,
	}
e.__index = e
e.new     = function(x,y,w,h,grid,tileset)
	local t =
	{
		x           = x,
		y           = y,
		w           = w,
		h           = h,
		grid        = grid,
		tileset     = tileset,
		isActive    = true,
		isBullet    = false,
	}
	return setmetatable(t,e)
end
-----------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------
local tw,th,gx,gy,gx2,gy2
function e:getTileRange()
	tw,th   = self.grid.tileWidth,self.grid.tileHeight
	gx,gy   = floor(self.x/tw)+1,floor(self.y/th)+1
	gx2,gy2 = ceil( (self.x+self.w)/tw ),ceil( (self.y+self.h)/th )
	return gx,gy,gx2,gy2
end
-----------------------------------------------------------
local grid,tileID,tile
function e:getTile(tx,ty)
	grid    = self.grid
	tileID  = grid[ty] and grid[ty][tx] or nil
	tile    = tileID and self.tileset[tileID] or nil
	return tile
end
-----------------------------------------------------------
-- custom collision callback
-- return true if tile/slope is collidable
function e:isResolvable(side,gx,gy,tile)
end
-----------------------------------------------------------
function e:rightSideResolve(gx,gy,gx2,gy2)
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newx    = self.x
	local tx,tile = gx2
	-- right sensor check
	for ty = gy,gy2 do 
		tile = self:getTile(tx,ty)
		if tile then
			-- check if tile is a slope
			if tile.horizontalHeightMap then
				local hmap = tile.horizontalHeightMap
				-- use endpoints to check for collision
				-- convert endpoints of side into height index
				local ti = gy ~= ty and 1 or floor(self.y-(ty-1)*th)+1
				local bi = gy2 ~= ty and th or ceil(self.y+self.h-(ty-1)*th)
				-- take the farthest position from the slope 
				local minx = min(self.x,tx*tw-self.w-hmap[ti],tx*tw-self.w-hmap[bi])
				-- if the new position is not same as the original position
				-- then we have a slope overlap
				if minx ~= self.x and self:isResolvable('right',tile,tx,ty) then
					newx = min(minx,newx)
				end
			elseif self:isResolvable('right',tile,tx,ty) then
				newx = (tx-1)*tw-self.w
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:leftSideResolve(gx,gy,gx2,gy2)
	local gx,gy,gx2,gy2 = self:getTileRange()
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newx    = self.x
	local tx,tile = gx
	
	for ty = gy,gy2 do 
		tile = self:getTile(tx,ty)
		if tile then
			if tile.horizontalHeightMap then
				local hmap = tile.horizontalHeightMap
				local ti   = gy ~= ty and 1 or floor(self.y-(ty-1)*th)+1
				local bi   = gy2 ~= ty and th or ceil(self.y+self.h-(ty-1)*th)
				local maxx = max(self.x,(tx-1)*tw+hmap[ti],(tx-1)*tw+hmap[bi])
				if maxx ~= self.x and self:isResolvable('left',tile,tx,ty) then
					newx = max(maxx,newx)
				end
			elseif self:isResolvable('left',tile,tx,ty) then
				newx = tx*tw
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:bottomSideResolve(gx,gy,gx2,gy2)
	local gx,gy,gx2,gy2 = self:getTileRange()
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newy    = self.y
	local ty,tile = gy2
	
	for tx = gx,gx2 do
		tile = self:getTile(tx,ty)
		if tile then
			if tile.verticalHeightMap then
				local hmap = tile.verticalHeightMap
				local li   = gx ~= tx and 1 or floor(self.x-(tx-1)*tw)+1
				local ri   = gx2 ~= tx and tw or ceil((self.x+self.w)-(tx-1)*tw)
				local miny = min(self.y,ty*th-self.h-hmap[li],ty*th-self.h-hmap[ri])
				if miny ~= self.y and self:isResolvable('bottom',tile,tx,ty) then
					newy = min(miny,newy)
				end
			elseif self:isResolvable('bottom',tile,tx,ty) then
				newy = (ty-1)*th-self.h
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:topSideResolve(gx,gy,gx2,gy2)
	local gx,gy,gx2,gy2 = self:getTileRange()
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newy    = self.y
	local ty,tile = gy
	
	for tx = gx,gx2 do
		tile = self:getTile(tx,ty)
		if tile then
			if tile.verticalHeightMap then
				local hmap = tile.verticalHeightMap
				local li   = gx ~= tx and 1 or floor(self.x-(tx-1)*tw)+1
				local ri   = gx2 ~= tx and tw or ceil((self.x+self.w)-(tx-1)*tw)
				local maxy = max(self.y,(ty-1)*th+hmap[li],(ty-1)*th+hmap[ri])
				if maxy ~= self.y and self:isResolvable('top',tile,tx,ty) then
					newy = max(maxy,newy)
				end
			elseif self:isResolvable('top',tile,tx,ty) then
				newy = ty*th
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:resolveX()
	local oldx          = self.x
	local gx,gy,gx2,gy2 = self:getTileRange()
	self:rightSideResolve(gx,gy,gx2,gy2)
	if oldx == self.x then self:leftSideResolve(gx,gy,gx2,gy2) end
end
-----------------------------------------------------------
function e:resolveY()
	local oldy          = self.y
	local gx,gy,gx2,gy2 = self:getTileRange()
	self:bottomSideResolve(gx,gy,gx2,gy2)
	if oldy == self.y then self:topSideResolve(gx,gy,gx2,gy2) end
end
-----------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------
function e:move(dx,dy)
	if not self.isActive then self.x,self.y = self.x+dx,self.y+dy return end
	if not self.isBullet then
		self.x = self.x+dx
		self:resolveX()
		self.y = self.y+dy
		self:resolveY()
		return
	end
	
	local mw,mh         = self.map.tileWidth,self.map.tileHeight
	local finalx,finaly = self.x+dx,self.y+dy
	local gx,gy,gx2,gy2,x,oldx,y,oldy,newx,newy,gd,least
	-----------------------------------------------------------
	-- x direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange()
	
	local gd,least
	if dx >= 0 then
		least   = min
		gx,gx2  = gx2,ceil((self.x+self.w+dx)/mw)-1
		gd      = 1
	elseif dx < 0 then
		least   = max
		gx2     = floor((self.x+dx)/mw)
		gd      = -1
	end
		
	-- continuous collision detection by moving cell by cell
	for tx = gx,gx2,gd do
		if dx >= 0 then 
			self.x = least((tx+1)*mw-self.w,finalx) 
		else 
			self.x = least(tx*mw,finalx) 
		end
		newx  = self.x
		self:resolveX()
		-- if there was a collision, quit movement
		if self.x ~= newx then break end
		oldy = self.y
		-- height correction so we can continue moving horizontally
		self:resolveY()
		-- get new height range
		if self.y ~= oldy then 
			_,gy,_,gy2 = self:getTileRange()
		end
	end	
	-----------------------------------------------------------
	-- y direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange()
	
	if dy >= 0 then
		least   = min
		gy,gy2  = gy2,ceil((self.y+self.h+dy)/mh)-1
		gd      = 1
	elseif dy < 0 then
		least   = max
		gy2     = floor((self.y+dy)/mh)
		gd      = -1
	end
		
	for ty = gy,gy2,gd do
		if dy >= 0 then 
			self.y = least((ty+1)*mh-self.h,finaly)
		else 
			self.y = least(ty*mh,finaly) 
		end
		newy  = self.y
		self:resolveY()
		if self.y ~= newy then break end
		oldx = self.x
		self:resolveX()
		if self.x ~= oldx then
			gx,_,gx2,_ = self:getTileRange()
		end
	end	
end
-----------------------------------------------------------
function e:moveTo(x,y)
	self:move(x-self.x,y-self.y)
end
-----------------------------------------------------------
function e:draw(mode)
	love.graphics.rectangle(mode,self.x,self.y,self.w,self.h)
end
-----------------------------------------------------------
return e