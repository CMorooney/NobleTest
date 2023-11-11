local gfx <const> = Graphics

JamScene = {}
class("JamScene").extends(NobleScene)

local player

function JamScene:init()
  JamScene.super.init(self)
  self.background = gfx.image.new("assets/images/background")

  player = Player(200, 185)
end

function JamScene:enter()
  self:addSprite(player)
end

function JamScene:drawBackground()
  JamScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

