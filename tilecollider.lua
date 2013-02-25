-- Tile Collider 2.1
local floor = math.floor
local ceil  = math.ceil
local max   = math.max
local min   = math.min
-----------------------------------------------------------
-- class
local e   = 
	{
	class    = 'collider',
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
function e:getTileRange(x,y,w,h)
	tw,th   = grid.tileWidth,grid.tileHeight
	gx,gy   = floor(x/tw)+1,floor(y/th)+1
	gx2,gy2 = ceil( (x+w)/tw ),ceil( (y+h)/th )
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
function e:isResolvable(side,tile,gx,gy)
end
-----------------------------------------------------------
function e:rightResolve(x,y,w,h)
	local gx,gy,gx2,gy2 = self:getTileRange(x,y,w,h)
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newx    = self.x
	local oldx    = newx
	local tile
	for tx = gx,gx2 do
		for ty = gy,gy2 do 
			tile = self:getTile(tx,ty)
			if tile then
				if tile.horizontalHeightMap then
					local hmap = tile.horizontalHeightMap
					-- index height map with 2 points
					local ti   = floor(y-(ty-1)*th)+1
					local bi   = ceil(y+h-(ty-1)*th)
					ti         = ti > th and th or ti < 1 and 1 or ti
					bi         = bi > th and th or bi < 1 and 1 or bi
					local minx = min(oldx,tx*tw-self.w-hmap[ti],tx*tw-self.w-hmap[bi])
					if minx ~= oldx and self:isResolvable('right',tile,tx,ty) then
						newx = min(minx,newx)
					end
				elseif self:isResolvable('right',tile,tx,ty) then
					newx = min( (tx-1)*tw-self.w , newx )
				end
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:leftResolve(x,y,w,h)
	local gx,gy,gx2,gy2 = self:getTileRange(x,y,w,h)
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newx    = self.x
	local oldx    = newx
	local tile
	for tx = gx,gx2 do
		for ty = gy,gy2 do 
			tile = self:getTile(tx,ty)
			if tile then
				if tile.horizontalHeightMap then
					local hmap = tile.horizontalHeightMap
					local ti   = floor(y-(ty-1)*th)+1
					local bi   = ceil(y+h-(ty-1)*th)
					ti         = ti > th and th or ti < 1 and 1 or ti
					bi         = bi > th and th or bi < 1 and 1 or bi
					local maxx = max(oldx,(tx-1)*tw+hmap[ti],(tx-1)*tw+hmap[bi])
					if maxx ~= oldx and self:isResolvable('left',tile,tx,ty) then
						newx = max(maxx,newx)
					end
				elseif self:isResolvable('left',tile,tx,ty) then
					newx = max( tx*tw , newx)
				end
			end
		end
	end
	self.x = newx
end
-----------------------------------------------------------
function e:bottomResolve(x,y,w,h)
	local gx,gy,gx2,gy2 = self:getTileRange(x,y,w,h)
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newy    = self.y
	local oldy    = newy
	local tile
	for ty = gy,gy2 do
		for tx = gx,gx2 do
			tile = self:getTile(tx,ty)
			if tile then
				if tile.verticalHeightMap then
					local hmap = tile.verticalHeightMap
					local li   = floor(x-(tx-1)*tw)+1
					local ri   = ceil((x+w)-(tx-1)*tw)
					li         = li > tw and tw or li < 1 and 1 or li
					ri         = ri > tw and tw or ri < 1 and 1 or ri
					local miny = min(oldy,ty*th-self.h-hmap[li],ty*th-self.h-hmap[ri])
					if miny ~= oldy and self:isResolvable('bottom',tile,tx,ty) then
						newy = min(miny,newy)
					end
				elseif self:isResolvable('bottom',tile,tx,ty) then
					newy = min( (ty-1)*th-self.h , newy )
				end
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:topResolve(x,y,w,h)
	local gx,gy,gx2,gy2 = self:getTileRange(x,y,w,h)
	local tw,th   = self.grid.tileWidth,self.grid.tileHeight
	local newy    = self.y
	local oldy    = newy
	local tile
	for ty = gy,gy2 do
		for tx = gx,gx2 do
			tile = self:getTile(tx,ty)
			if tile then
				if tile.verticalHeightMap then
					local hmap = tile.verticalHeightMap
					local li   = floor(x-(tx-1)*tw)+1
					local ri   = ceil((x+w)-(tx-1)*tw)
					li         = li > tw and tw or li < 1 and 1 or li
					ri         = ri > tw and tw or ri < 1 and 1 or ri
					local maxy = max(oldy,(ty-1)*th+hmap[li],(ty-1)*th+hmap[ri])
					if maxy ~= oldy and self:isResolvable('top',tile,tx,ty) then
						newy = max(maxy,newy)
					end
				elseif self:isResolvable('top',tile,tx,ty) then
					newy = max( ty*th , newy )
				end
			end
		end
	end
	self.y = newy
end
-----------------------------------------------------------
function e:resolveX()
	local x,y,w,h = self.x,self.y,self.w,self.h
	self:rightResolve(x+w/2,y,w/2,h)
	if self.x ~= x then return end
	self:leftResolve(x,y,w/2,h)
end
-----------------------------------------------------------
function e:resolveY()
	local x,y,w,h = self.x,self.y,self.w,self.h
	self:bottomResolve(x,y+h/2,w,h/2)
	if self.y ~= y then return end
	self:topResolve(x,y,w,h/2)
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
	local gx,gy,gx2,gy2,newx,newy,gd,least
	-----------------------------------------------------------
	-- x direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange(self.x,self.y,self.w,self.h)
	
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
		
	for tx = gx,gx2,gd do
		if dx >= 0 then 
			self.x = least((tx+1)*mw-self.w,finalx) 
		else 
			self.x = least(tx*mw,finalx) 
		end
		newx  = self.x
		self:resolveX()
		if self.x ~= newx then break end
		self:resolveY()
	end	
	-----------------------------------------------------------
	-- y direction collision detection
	gx,gy,gx2,gy2 = self:getTileRange(self.x,self.y,self.w,self.h)
	
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
		self:resolveX()
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
