local pd <const> = playdate
local gfx <const> = Graphics

Player = {}

class("Player").extends(AnimatedSprite)

local player_imagetable <const> = gfx.imagetable.new("assets/images/player")

local scythe

function Player:init(x, y)
  Player.super.init(self, player_imagetable)

  self:setTag(TAGS.Player)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("idle", 1, 9, { tickStep = 4 }, true)
  self:addState("accel", 10, 12, { tickStep = 4 })
  self:addState("run", 12, 13, { tickStep = 4 })

  self.movement_speed = 2
  self.x_velocity = 0
  self:moveTo(x, y)

  self.facing_right = false
  self.is_attacking= false

  self:setCollideRect(10, 0, 20, 42)
  self:setGroups({ TAGS.Player })
  self:setCollidesWithGroups({ TAGS.Victim })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap
end

function Player:initScythe()
  scythe = Scythe(200, 180)
  scythe:setZIndex(2)
  scythe:add()
end

function Player:attack()
  if self.is_attacking then
    return
  end

  self.is_attacking = true
  scythe:attack()
  pd.timer.new(800, function()
    self.is_attacking = false
  end)
end

function Player:update()
  Player.super.update(self)

  if pd.buttonIsPressed(pd.kButtonLeft) then
    self.x_velocity = -1 * self.movement_speed
    self.facing_right = false
    self:changeState("run")
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self.x_velocity = 1 * self.movement_speed
    self.facing_right = true
    self:changeState("run")
  else
    self.x_velocity = 0
    self:changeState("idle")
  end

  if self.facing_right then
    self:setImageFlip(gfx.kImageUnflipped)
  else
    self:setImageFlip(gfx.kImageFlippedX)
  end

  self:moveWithCollisions(self.x + self.x_velocity, self.y)
  self:updateScythe()
end

function Player:updateScythe()
  local xmod = 0
  if self.facing_right  then
    xmod = 10
  else
    xmod = -10
  end

  scythe:moveTo(self.x + xmod, scythe.y)
  scythe.facing_right = self.facing_right
end

