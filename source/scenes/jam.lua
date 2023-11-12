local gfx <const> = Graphics
local pdtimer <const> = playdate.timer

JamScene = {}
class("JamScene").extends(NobleScene)

local player
local home
local playerHealthSprite
local homeHealthSprite

local playerHealthValue = 1;
local homeHealthValue = 1;

local victimSpawnTimer = nil

function JamScene:init()
  JamScene.super.init(self)
  self.background = gfx.image.new("assets/images/background")

  player = Player(200, 185)
  home = Home()
  playerHealthSprite = HealthBar()
  homeHealthSprite = HealthBar()

  player:setZIndex(1)
end

function JamScene:enter()
  self:addSprite(player)
  self:addSprite(home)
  self:addSprite(playerHealthSprite)

  player:initScythe()

  local function ghostReachedHome()
    self:performHomeDamage()
  end
  local function playerWasPunched()
    self:performPlayerDamage()
  end

  victimSpawnTimer = pdtimer.new(1000)
  -- victimSpawnTimer.repeats = true
  victimSpawnTimer.timerEndedCallback = function(_)
    local xpos = math.random(400)
    local victim = Victim(xpos, 175, player.x, ghostReachedHome, playerWasPunched)
    victim:setZIndex(1)
    self:addSprite(victim)
  end
end

function JamScene:performHomeDamage()
  homeHealthValue = homeHealthValue - 0.1
  if homeHealthValue <= 0 then
    self:gameOver()
  end
end

function JamScene:performPlayerDamage()
  playerHealthValue = playerHealthValue - 0.1
  if playerHealthValue <= 0 then
    playerHealthSprite:setPercent(0)
    self:gameOver()
  else
    playerHealthSprite:setPercent(playerHealthValue)
  end
end

function JamScene:gameOver()
  print("game over")
end

function JamScene:update()
  for _, sprite in ipairs(gfx.sprite.getAllSprites()) do
    if sprite:getTag() == TAGS.Victim then
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

