local pd <const> = playdate
local gfx <const> = Graphics

Player = {}

class("Player").extends(AnimatedSprite)

local player_imagetable <const> = gfx.imagetable.new("assets/images/player")
local facing_right = false

function Player:init(x, y)
  Player.super.init(self, player_imagetable)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("idle_left", 1, 9, { tickStep = 4, flip = playdate.geometry.kFlippedX }, true)
  self:addState("idle_right", 1, 9, { tickStep = 4 })
  self:addState("accel", 10, 12, { tickStep = 4 })
  self:addState("run_left", 12, 13, { tickStep = 4, flip = playdate.geometry.kFlippedX })
  self:addState("run_right", 12, 13, { tickStep = 4 })

  self.movement_speed = 2
  self.x_velocity = 0
  self:moveTo(x, y)
end

function Player:update()
  Player.super.update(self)

  if pd.buttonIsPressed(pd.kButtonLeft) then
    self.x_velocity = -1 * self.movement_speed
    facing_right = false
    self:changeState("run_left")
  elseif pd.buttonIsPressed(pd.kButtonRight) then
    self.x_velocity = 1 * self.movement_speed
    facing_right = true
    self:changeState("run_right")
  else
    self.x_velocity = 0
    if facing_right then
      self:changeState("idle_right")
    else
      self:changeState("idle_left")
    end
  end

  self:moveBy(self.x_velocity, 0)
end

