local pd <const> = playdate
local gfx <const> = Graphics

Home = {}

class("Home").extends(gfx.sprite)

function Home:init()
  Home.super.init(self)

  self:setCenter(0.5, 0)
  self:moveTo(200, 0)

  self:setImage(gfx.image.new("assets/images/home"))
end
