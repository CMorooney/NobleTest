local gfx <const> = Graphics

JamScene = {}
class("JamScene").extends(NobleScene)

local player
local victim

function JamScene:init()
  JamScene.super.init(self)
  self.background = gfx.image.new("assets/images/background")

  player = Player(200, 185)
  victim = Victim(100, 175, player.x)

  player:setZIndex(1)
  victim:setZIndex(1)
end

function JamScene:enter()
  self:addSprite(player)
  self:addSprite(victim)
end

function JamScene:update()
  victim:setTarget(player.x)
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

