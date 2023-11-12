local pd <const> = playdate
local gfx <const> = Graphics

StartScene = {}
class("StartScene").extends(NobleScene)

local selectedIndex = 0

function StartScene:init()
  StartScene.super.init(self)
  self.background = gfx.image.new("assets/images/gamestart")
end

function StartScene:update()
  StartScene.super.update(self)

  gfx.setImageDrawMode(pd.graphics.kDrawModeFillWhite)

  local startText = "start"
  local settingsText = "settings"
  if selectedIndex == 0 then
    startText = "*"..startText.."*"
  else
    settingsText = "*"..settingsText.."*"
  end
  gfx.drawText(startText, 155, 190)
  gfx.drawText(settingsText, 205, 190)
  gfx.setImageDrawMode(pd.graphics.kDrawModeCopy)
end

function StartScene:drawBackground()
  StartScene.super.drawBackground(self)
  self.background:draw(0, 0)
end

local toggleOption = function ()
  if selectedIndex == 0 then selectedIndex = 1
  else selectedIndex = 0 end
end

local selectOption = function()
  if selectedIndex == 0 then
    Noble.transition(JamScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  else
    -- todo:
    -- Noble.transition(SettingsScene, 2, Noble.Transition.DipToBlack, {}, { alwaysRedraw = false })
  end
end

StartScene.inputHandler = {
  leftButtonUp = function() toggleOption() end,
  rightButtonUp = function() toggleOption() end,
  AButtonUp = function() selectOption() end
}

