import("CoreLibs/object")

class("Bullet").extends()

function Bullet:init(pos, dir, speed, size)
	Bullet.super.init(self)
	self.pos = pos
	self.dir = dir
	self.rect = playdate.geometry.rect.new(pos.x - size / 2, pos.y - size / 2, size, size)
	self.speed = speed
	self.size = size
end

function Bullet:move()
	self.pos = self.pos + self.dir:scaledBy((deltaTime / 1000) * self.speed)
end

function Bullet:draw()
	gfx.setColor(gfx.kColorBlack)
	gfx.fillRect(self.pos.x - self.size / 2, self.pos.y, self.size, self.size)
end

function Bullet:onUpdate()
	self:move()
end
