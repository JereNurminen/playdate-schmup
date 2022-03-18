import("CoreLibs/object")

class("Bullet").extends()

function Bullet:init(pos, dir, speed, size)
	Bullet.super.init(self)
	self.pos = pos
	self.dir = dir
	self.rect = playdate.geometry.rect.new(pos.x - size / 2, pos.y - size / 2, size, size)
	self.speed = speed
	self.size = size
	self.active = true
end

function Bullet:move()
	self.pos = self.pos + self.dir:scaledBy((deltaTime / 1000) * self.speed)
end

function Bullet:draw()
	if self.active then
		gfx.setColor(gfx.kColorBlack)
		gfx.fillRect(self.pos.x - self.size / 2, self.pos.y, self.size, self.size)
	end
end

function Bullet:checkCollisions()
	for i, enemy in ipairs(entities.enemies) do
		if enemy.rect:containsPoint(self.pos:unpack()) then
			self:kill()
			enemy:onHit()
		end
	end
end

function Bullet:kill()
	self.active = false
end

function Bullet:checkOutOfBounds()
	if self.pos.x < -unspawnMargin
	or self.pos.x > screenSize.x + unspawnMargin 
	or self.pos.y < -unspawnMargin
	or self.pos.y > screenSize.y + unspawnMargin then
		self:kill()
	end
end

function Bullet:onUpdate()
	if self.active then
		self:move()
		self:checkCollisions()
		self:checkOutOfBounds()
	end
end
