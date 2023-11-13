local pd <const> = playdate
local gfx <const> = Graphics

InstructionsScene = {}
class("InstructionsScene").extends(NobleScene)

function InstructionsScene:init()
  InstructionsScene.super.init(self)
  self.background = gfx.image.new("assets/images/instructions")
end

function InstructionsScene:drawBackground()
  InstructionsScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

local goBack = function()
    Noble.transition(StartScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
end

InstructionsScene.inputHandler = {
  BButtonUp = function() goBack() end
}


