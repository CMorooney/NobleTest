local pd <const> = playdate
local gfx <const> = Graphics

Scythe = {}
class("Scythe").extends(AnimatedSprite)

local scythe_imagetable <const> = gfx.imagetable.new("assets/images/scythe")

function Scythe:init(x, y)
  Scythe.super.init(self, scythe_imagetable)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("attack", 1, 9, { tickStep = 1, loop = false, onAnimationEndEvent = function() self:remove() end })

  self:moveTo(x, y)

  self:setCollideRect(0, 0, 75, 75)
  self:setGroups({ 1 })
  self:setCollidesWithGroups({ 2 })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.facing_right = false
  self.is_attacking = false
end

function Scythe:update()
  Scythe.super.update(self)

  if self.facing_right then
    self:setImageFlip(gfx.kImageUnflipped)
  else
    self:setImageFlip(gfx.kImageFlippedX)
  end

  local _, _, _, numberOfCollisions = self:checkCollisions(self.x, self.y)
  if numberOfCollisions > 0 then
    print("collide")
  end
end

function Scythe:attack()
  self:add()
  self:playAnimation()
end

