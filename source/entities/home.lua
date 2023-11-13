local pd <const> = playdate
local gfx <const> = Graphics

Home = {}

class("Home").extends(gfx.sprite)

local anchor_x = 200

function Home:init()
  Home.super.init(self)

  self:setCenter(0.5, 0)
  self:moveTo(anchor_x, 0)

  self:setImage(gfx.image.new("assets/images/home"))
end

function Home:shake(shakeTime, shakeMagnitude)
    local shakeTimer = pd.timer.new(shakeTime, shakeMagnitude, 0)

    shakeTimer.updateCallback = function(timer)
        local magnitude = math.floor(timer.value)
        local shakeX = math.random(-magnitude, magnitude)
        local shakeY = math.random(-magnitude, magnitude)
        self:moveTo(anchor_x + shakeX, 0 + shakeY)
    end

    shakeTimer.timerEndedCallback = function()
        self:moveTo(anchor_x, 0)
    end
end
