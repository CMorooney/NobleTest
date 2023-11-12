local pd <const> = playdate
local gfx <const> = Graphics

Victim = {}

class("Victim").extends(AnimatedSprite)

local victim_imagetable <const> = gfx.imagetable.new("assets/images/victim")

function Victim:init(x, y, target_x)
  Victim.super.init(self, victim_imagetable)

  self.target_x = target_x

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  local function attackComplete()
    self:setImage(victim_imagetable:getImage(1))
  end

  self:addState("idle", 1, 1, { tickStep = 4 }, true)
  self:addState("walk", 2, 7, { tickStep = 4 })
  self:addState("slam",
                8,
                11,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                })
  self:addState("backhand",
                12,
                14,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                }
  )
  self:addState("punch",
                15,
                16,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                }
  )
  self:addState("die",
                17,
                20,
                {
                  tickStep = 5,
                  loop = false,
                  onAnimationEndEvent = function()
                    self:setImage(victim_imagetable:getImage(20))
                    self:setCollisionsEnabled(false)
                    pd.timer.new(300, function()
                      -- todo: ghost
                    end)
                  end
                }
  )

  self:moveTo(x, y)

  self:setCollideRect(7, 17, 17, 48)
  self:setGroups({ 2 })
  self:setCollidesWithGroups({ 1 })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.flipValue = gfx.kImageUnflipped
  self.facing_right = false
  self.is_dead = false
  self.is_attacking = false
end

function Victim:setTarget(x)
  self.target_x = x
end

function Victim:die()
  if self.is_dead then
    return
  end

  self:changeState("die")
  self.is_dead = true
end

function Victim:attack()
  if self.is_attacking then
    return
  end

  local attackIndex = math.random(3)

  if attackIndex == 0 then
    self:changeState("slam")
  elseif attackIndex == 1 then
    self:changeState("backhand")
  elseif attackIndex == 3 then
    self:changeState("punch")
  end

  self.is_attacking = true
  pd.timer.new(800, function()
    self.is_attacking = false
  end)
end

function Victim:update()
  Victim.super.update(self)
  self:setImageFlip(self.flipValue)

  if self.is_dead then
    return
  end

  if math.abs(self.target_x - self.x) < 20 then
    self:attack()
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
    self.flipValue = gfx.kImageUnflipped
  else
    self.flipValue = gfx.kImageFlippedX
  end

  self:moveWithCollisions(x, self.y)
end
