local pd <const> = playdate
local gfx <const> = Graphics
local sound <const> = playdate.sound

local option_selected_sample <const> = sound.sample.new("assets/audio/one_shots/gamestart")

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
  option_selected_sample:play()
  Noble.transition(StartScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
end

InstructionsScene.inputHandler = {
  BButtonUp = function() goBack() end
}


