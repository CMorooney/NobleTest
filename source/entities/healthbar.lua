local pd <const> = playdate
local gfx <const> = Graphics

HealthBar = {}
class("HealthBar").extends(gfx.sprite)

local healthbar_imagetable <const> = gfx.imagetable.new("assets/images/healthbar")
local totalSprites <const> = 13

function HealthBar:init()
  HealthBar.super.init(self)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:setCenter(0, 0)
  self:moveTo(200, 100)
  self:setPercent(1)
end

function HealthBar:setPercent(p)
  local imageIndex = math.ceil(totalSprites * p)
  if imageIndex > 0 then
    self:setImage(healthbar_imagetable:getImage(imageIndex))
  else
    self:setImage(healthbar_imagetable:getImage(1))
  end
end
