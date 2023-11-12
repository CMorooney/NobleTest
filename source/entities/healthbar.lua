local pd <const> = playdate
local gfx <const> = Graphics

HealthBar = {}
class("HealthBar").extends(gfx.sprite)

local healthbar_imagetable <const> = gfx.imagetable.new("assets/images/healthbar")
local totalSprites <const> = 13

function HealthBar:init(x, y, percent)
  HealthBar.super.init(self)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self.original_x = x
  self.original_y = y

  self:setCenter(0, 0)
  self:moveTo(x, y)
  self:setPercent(percent)
end

function HealthBar:setPercent(p, animate)
  local imageIndex = math.ceil(totalSprites * p)
  if imageIndex > 0 then
    self:setImage(healthbar_imagetable:getImage(imageIndex))
  else
    self:setImage(healthbar_imagetable:getImage(1))
  end

  if animate == true or animate == nil then
    self:shake(200, 3)
  end
end

function HealthBar:shake(shakeTime, shakeMagnitude)
    local shakeTimer = pd.timer.new(shakeTime, shakeMagnitude, 0)

    shakeTimer.updateCallback = function(timer)
        local magnitude = math.floor(timer.value)
        local shakeX = math.random(-magnitude, magnitude)
        local shakeY = math.random(-magnitude, magnitude)
        self:moveTo(self.original_x + shakeX, self.original_y + shakeY)
    end

    shakeTimer.timerEndedCallback = function()
        self:moveTo(self.original_x, self.original_y)
    end
end
