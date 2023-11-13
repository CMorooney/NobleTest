local pd <const> = playdate
local gfx <const> = Graphics
local sound <const> = playdate.sound

GameOverScene = {}
class("GameOverScene").extends(NobleScene)

local selectedIndex = 0
local selection_change_sample <const> = sound.sample.new("assets/audio/one_shots/menuselect")
local option_selected_sample <const> = sound.sample.new("assets/audio/one_shots/gamestart")

function GameOverScene:init()
  GameOverScene.super.init(self)
  self.background = gfx.image.new("assets/images/gameover")
end

function GameOverScene:update()
  GameOverScene.super.update(self)

  gfx.setImageDrawMode(pd.graphics.kDrawModeFillWhite)

  local exitText = "exit"
  local againText = "again"
  if selectedIndex == 0 then
    exitText = "*"..exitText.."*"
  else
    againText = "*"..againText.."*"
  end
  gfx.drawText(exitText, 55, 140)
  gfx.drawText(againText, 55, 157)
  gfx.setImageDrawMode(pd.graphics.kDrawModeCopy)
end

function GameOverScene:drawBackground()
  GameOverScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

local toggleOption = function ()
  selection_change_sample:play()
  if selectedIndex == 0 then selectedIndex = 1
  else selectedIndex = 0 end
end

local selectOption = function()
  option_selected_sample:play()
  if selectedIndex == 0 then
    Noble.transition(StartScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  else
    Noble.transition(JamScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  end
end

GameOverScene.inputHandler = {
  upButtonUp = function() toggleOption() end,
  downButtonUp = function() toggleOption() end,
  AButtonUp = function() selectOption() end
}

