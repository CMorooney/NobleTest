local gfx <const> = Graphics

Victim = {}

class("Victim").extends(AnimatedSprite)

local victim_imagetable <const> = gfx.imagetable.new("assets/images/victim")

function Victim:init(x, y, target_x)
  Victim.super.init(self, victim_imagetable)

  self.target_x = target_x

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("idle", 1, 1, { tickStep = 4 }, true)
  self:addState("walk", 2, 7, { tickStep = 4 })
  self:addState("slam", 8, 11, { tickStep = 4, loop = false })
  self:addState("backhand", 12, 14, { tickStep = 4, loop = false })
  self:addState("punch", 15, 16, { tickStep = 4, loop = false })
  self:addState("die", 17, 20, { tickStep = 3, loop = false})

  self.movement_speed = 1
  self.x_velocity = 0
  self:moveTo(x, y)

  self:setCollideRect(7, 17, 17, 48)
  self:setGroups({ 2 })
  self:setCollidesWithGroups({ 1 })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.facing_right = false
end

function Victim:setTarget(x)
  self.target_x = x
end

function Victim:update()
  Victim.super.update(self)

  if math.abs(self.target_x - self.x) < 20 then
    -- todo: attack
    self:changeState("idle")
    return
  end

  local x = math.lerp(self.x, self.target_x, 0.01)

  if self.x < x then
    self.facing_right = true
    self:changeState("walk")
  elseif self.x > x then
    self.facing_right = false
    self:changeState("walk")
  else
    self:changeState("idle")
  end

  if self.facing_right then
    self:setImageFlip(gfx.kImageUnflipped)
  else
    self:setImageFlip(gfx.kImageFlippedX)
  end

  self:moveWithCollisions(x, self.y)
end
