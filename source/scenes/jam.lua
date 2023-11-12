local gfx <const> = Graphics
local pdtimer <const> = playdate.timer

JamScene = {}
class("JamScene").extends(NobleScene)

local player

local victimSpawnTimer = nil

function JamScene:init()
  JamScene.super.init(self)
  self.background = gfx.image.new("assets/images/background")

  player = Player(200, 185)

  player:setZIndex(1)
end

function JamScene:enter()
  self:addSprite(player)
  player:initScythe()

  victimSpawnTimer = pdtimer.new(1000)
  victimSpawnTimer.repeats = true
  victimSpawnTimer.timerEndedCallback = function(_)
    local xpos = math.random(400)
    local victim = Victim(xpos, 175, player.x)
    victim:setZIndex(1)
    self:addSprite(victim)
  end
end

function JamScene:update()
  for _, sprite in ipairs(gfx.sprite.getAllSprites()) do
    if sprite:getTag() == 6 then
      sprite:setTarget(player.x)
    end
  end
end

function JamScene:drawBackground()
  JamScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

JamScene.inputHandler = {
  cranked = function(_, acceleratedChange)
    if acceleratedChange > 75 then
      player:attack()
    end
  end
}

