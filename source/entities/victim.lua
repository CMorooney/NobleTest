local pd <const> = playdate
local gfx <const> = Graphics

Victim = {}
class("Victim").extends(AnimatedSprite)

function Victim:init(x,
                     y,
                     target_x,
                     victim_imagetable,
                     ghost_imagetable,
                     ghostsplode_imagetable,
                     homeCallback,
                     punchedCallback)

  Victim.super.init(self, victim_imagetable)

  self.victim_imagetable = victim_imagetable
  self.ghost_imagetable = ghost_imagetable
  self.ghostsplode_imagetable = ghostsplode_imagetable

  self.homeCallback = homeCallback
  self.punchedCallback = punchedCallback

  self:setTag(TAGS.Victim)

  self.target_x = target_x

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:initHumanAnimations()
  self:initGhostAnimations()

  self:moveTo(x, y)

  self:setCollideRect(5, 17, 20, 48)
  self:setGroups({ TAGS.Victim, TAGS.Ghost })
  self:setCollidesWithGroups({ TAGS.Player, TAGS.Soundwave })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.flipValue = gfx.kImageUnflipped
  self.facing_right = false
  self.is_attacking = false
end

function Victim:initHumanAnimations()
  local function attackComplete()
    local _, _, _, numberOfCollisions = self:checkCollisions(self.x, self.y)
    if numberOfCollisions > 0 then
     self.punchedCallback()
    end

    self:setImage(self.victim_imagetable:getImage(1))
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
                    self:setImage(self.victim_imagetable:getImage(20))
                    pd.timer.new(800, function()
                      self.imagetable = self.ghost_imagetable
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
  self:addState("ghostsplode", 1, 74, {
    loop = false,
    onAnimationEndEvent = function()
      self:remove()
    end
  })
end

function Victim:setTarget(x)
  self.target_x = x
end

function Victim:die()
  local tag = self:getTag()
  if tag == TAGS.Body then
    return
  end

  if tag == TAGS.Victim then
    self:changeState("human_die")
    self:setTag(TAGS.Body)
  elseif tag == TAGS.Ghost then
    self.imagetable = self.ghostsplode_imagetable
    self:changeState("ghostsplode")
  end
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

function Victim:atHome()
  local xDiff = math.abs(200 - self.x)
  local yDiff = math.abs(-50 - self.y)
  if yDiff < 25 and xDiff < 40 then
    return true
  end
  return false
end

function Victim:update()
  Victim.super.update(self)

  self:setImageFlip(self.flipValue)

  local tag = self:getTag()
  if tag == TAGS.Body then
    return
  elseif tag == TAGS.Ghost and self:atHome() then
    self:remove()
    self.homeCallback()
  end

  local x = math.lerp(self.x, self.target_x, 0.01)
  local y = self.y

  if tag == TAGS.Ghost then
    y = math.lerp(self.y, -50, 0.01);
  elseif math.abs(self.target_x - self.x) < 20 then
    self:attack()
    return
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
