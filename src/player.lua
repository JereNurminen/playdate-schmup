class("Player").extends()

local speed <const> = 50
local shootCooldown <const> = 350
local size = 20
local halfSize = size / 2  

local bulletSpeed <const> = 150
local bulletWidth <const> = 3
local shootCooldown <const> = 350

function Player:init(pos)
	Player.super.init(self)
	self.tag = "player"
	
	self.pos = pos
	self.spin = playdate.geometry.affineTransform.new()
	self.ship = playdate.geometry.polygon.new(
		pos.x,
		pos.y - halfSize,
		pos.x - halfSize,
		pos.y + halfSize,
		pos.x,
		pos.y + halfSize / 2,
		pos.x + halfSize,
		pos.y + halfSize,
		pos.x,
		pos.y - halfSize
	)
	self.nosePos = self.ship:getPointAt(1)
	self.active = true
	self.cooldownTimer = shootCooldown
end

function Player:draw()
	gfx.setLineWidth(2)
	gfx.setColor(gfx.kColorBlack)
	gfx.fillPolygon(self.ship)
end

function Player:move()
	local x, y
	if inputs.up then
		y = -1
	elseif inputs.down then
		y = 1
	else
		y = 0 
	end	
	
	if inputs.left then
		x = -1
	elseif inputs.right then
		x = 1
	else
		x = 0 
	end	
	
	if x == 0 and y == 0 then
		playerIsMoving = false
	else
		if not gameHasStarted then
			startGame()
			self:shoot()
		end
		playerIsMoving = true
	end
	
	
	local movement = playdate.geometry.vector2D.new(x, y)
		:normalized()
		:scaledBy(deltaTime / 1000 * speed)
	self.pos += movement
	
	self.ship = playdate.geometry.polygon.new(
		self.pos.x,
		self.pos.y - halfSize,
		self.pos.x - halfSize,
		self.pos.y + halfSize,
		self.pos.x,
		self.pos.y + halfSize / 2,
		self.pos.x + halfSize,
		self.pos.y + halfSize,
		self.pos.x,
		self.pos.y - halfSize
	)
	
	playdate.geometry.affineTransform.new()
		:rotatedBy(inputs.crank, self.pos.x, self.pos.y)
		:transformPolygon(self.ship)
	
	self.nosePos = self.ship:getPointAt(1)
end

function Player:shoot()
	table.insert(
		entities.bullets,
		Bullet(
			self.nosePos,
			(self.nosePos - self.pos):normalized(),
			bulletSpeed,
			bulletWidth
		)
	)
end

function Player:die()
	gameOver()
end

function Player:checkCollisions()
	for i, e in ipairs(entities.wave.enemies) do
		if self.ship:intersects(e.enemy.rect:toPolygon()) then
			self:die()
		end
	end
end

function Player:onUpdate()
	if gameActive then
		self:move()
		if gameHasStarted then self:checkCollisions() end
		if gameHasStarted and self.cooldownTimer < 0 then
			self:shoot()
			self.cooldownTimer = shootCooldown
		else 
			self.cooldownTimer -= deltaTime
		end
	end
end
