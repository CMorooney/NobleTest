local pd <const> = playdate
local gfx <const> = Graphics

Victim = {}
class("Victim").extends(AnimatedSprite)

local victim_imagetable <const> = gfx.imagetable.new("assets/images/victim")
local ghost_imagetable <const> = gfx.imagetable.new("assets/images/ghost")

function Victim:init(x, y, target_x)
  Victim.super.init(self, victim_imagetable)

  self:setTag(TAGS.Victim)

  self.target_x = target_x

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:initHumanAnimations()
  self:initGhostAnimations()

  self:moveTo(x, y)

  self:setCollideRect(7, 17, 17, 48)
  self:setGroups({ 2 })
  self:setCollidesWithGroups({ 1 })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.flipValue = gfx.kImageUnflipped
  self.facing_right = false
  self.is_attacking = false
end

function Victim:initHumanAnimations()
  local function attackComplete()
    self:setImage(victim_imagetable:getImage(1))
  end

  self:addState("human_idle", 1, 1, { tickStep = 4 }, true)
  self:addState("human_walk", 2, 7, { tickStep = 4 })
  self:addState("human_slam",
                8,
                11,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                })
  self:addState("human_backhand",
                12,
                14,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                }
  )
  self:addState("human_punch",
                15,
                16,
                {
                  tickStep = 4,
                  loop = false,
                  onAnimationEndEvent = attackComplete
                }
  )
  self:addState("human_die",
                17,
                20,
                {
                  tickStep = 5,
                  loop = false,
                  onAnimationEndEvent = function()
                    self:setImage(victim_imagetable:getImage(20))
                    self:setCollisionsEnabled(false)
                    pd.timer.new(300, function()
                      self.imagetable = ghost_imagetable
                      self:changeState("ghost_idle_front")
                      self:setTag(TAGS.Ghost)
                      self.target_x = 200
                    end)
                  end
                }
  )

end

function Victim:initGhostAnimations()
  self:addState("ghost_idle_front", 7, 9, { tickStep = 4 })
  self:addState("ghost_idle_back", 1, 3, { tickStep = 4 })
  self:addState("ghost_run_right", 4, 6, { tickStep = 4 })
  self:addState("ghost_run_left", 10, 12, { tickStep = 4 })
end

function Victim:setTarget(x)
  self.target_x = x
end

function Victim:die()
  local tag = self:getTag()
  if tag == TAGS.Body or tag == TAGS.Ghost then
    return
  end

  self:changeState("human_die")
  self:setTag(TAGS.Body)
end

function Victim:attack()
  if self.is_attacking then
    return
  end

  local attackIndex = math.random(3)

  if attackIndex == 0 then
    self:changeState("human_slam")
  elseif attackIndex == 1 then
    self:changeState("human_backhand")
  elseif attackIndex == 3 then
    self:changeState("human_punch")
  end

  self.is_attacking = true
  pd.timer.new(800, function()
    self.is_attacking = false
  end)
end

function Victim:MovementAnim(tag)
  if tag == TAGS.Victim then
    self:changeState("human_walk")
  elseif tag == TAGS.Ghost then
    if math.abs(self.x - 200) > 20 then
      self:changeState("ghost_run_right")
    else
      self:changeState("ghost_idle_front")
    end
  end
end

function Victim:IdleAnim(tag)
  if tag == TAGS.Victim then
    self:changeState("human_idle")
  elseif tag == TAGS.Ghost then
    self:changeState("ghost_idle_front")
  end
end

function Victim:update()
  Victim.super.update(self)

  self:setImageFlip(self.flipValue)

  local tag = self:getTag()
  if tag == TAGS.Body then
    return
  end

  local x = math.lerp(self.x, self.target_x, 0.01)
  local y = self.y

  if tag == TAGS.Ghost then
    y = math.lerp(self.y, 0, 0.001);
  elseif math.abs(self.target_x - self.x) < 20 then
    self:attack()
  end


  if self.x < x then
    self.facing_right = true
    self:MovementAnim(tag)
  elseif self.x > x then
    self.facing_right = false
    self:MovementAnim(tag)
  else
    self:IdleAnim(tag)
  end

  if self.facing_right then
    self.flipValue = gfx.kImageUnflipped
  else
    self.flipValue = gfx.kImageFlippedX
  end

  self:moveWithCollisions(x, y)
end
