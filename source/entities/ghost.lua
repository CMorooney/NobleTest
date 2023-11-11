local gfx <const> = Graphics

Ghost = {}

class("Ghost").extends(AnimatedSprite)

local ghost_imagetable <const> = gfx.imagetable.new("assets/images/ghost")

function Ghost:init(x, y, target_x)
  Ghost.super.init(self, ghost_imagetable)

  self.target_x = target_x

  self:addState("idle_front", 7, 9, { tickStep = 4 }, true)
  self:addState("idle_back", 1, 3, { tickStep = 4 })
  self:addState("run_right", 4, 6, { tickStep = 4 })
  self:addState("run_left", 10, 12, { tickStep = 4 })

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:moveTo(x, y)

  self.facing_right = false
end

function Ghost:setTarget(x)
  self.target_x = x
end

function Ghost:update()
  Ghost.super.update(self)

  local x = math.lerp(self.x, self.target_x, 0.01)

  if self.x < x then
    self:changeState("run_right")
  elseif self.x > x then
    self:changeState("run_left")
  else
    self:changeState("idle_front")
  end

  self:moveWithCollisions(x, self.y)
end

