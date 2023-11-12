local pd <const> = playdate
local gfx <const> = Graphics

GameOverScene = {}
class("GameOverScene").extends(NobleScene)

local selectedIndex = 0

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
  gfx.drawText(exitText, 155, 190)
  gfx.drawText(againText, 205, 190)
  gfx.setImageDrawMode(pd.graphics.kDrawModeCopy)
end

function GameOverScene:drawBackground()
  GameOverScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

local toggleOption = function ()
  if selectedIndex == 0 then selectedIndex = 1
  else selectedIndex = 0 end
end

local selectOption = function()
  if selectedIndex == 0 then
    Noble.transition(StartScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  else
    Noble.transition(JamScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  end
end

GameOverScene.inputHandler = {
  leftButtonUp = function() toggleOption() end,
  rightButtonUp = function() toggleOption() end,
  AButtonUp = function() selectOption() end
}

