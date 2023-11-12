local gfx <const> = Graphics
local pdtimer <const> = playdate.timer

JamScene = {}
class("JamScene").extends(NobleScene)

local player
local home

local playerPortraitImage <const> = gfx.image.new("/assets/images/player_portrait")
local playerPortraitSprite
local playerHealthSprite

local ghostPortraitImage <const> = gfx.image.new("/assets/images/ghost_portrait")
local ghostPortraitSprite
local homeHealthSprite

local speakerImage <const> = gfx.image.new("/assets/images/speaker")
local speakerLeftSprite
local speakerRightSprite

local soundwave_imagetable <const> = gfx.imagetable.new("assets/images/soundwave")
local soundwaveLeftSprite
local soundwaveRightSprite

local playerHealthValue = 1;
local homeHealthValue = 0;

local victimSpawnTimer = nil

function JamScene:init()
  JamScene.super.init(self)
  self.background = gfx.image.new("assets/images/background")

  player = Player(200, 185)
  home = Home()
  playerHealthSprite = HealthBar(25, 222, playerHealthValue)
  homeHealthSprite = HealthBar(300, 222, homeHealthValue)
  self:initPlayerPortrait()
  self:initGhostPortrait()
  self:initSpeakerSprites()
  self:initSoundwaveSprites()

  player:setZIndex(1)
end

function JamScene:initPlayerPortrait()
  playerPortraitSprite = gfx.sprite.new(playerPortraitImage)
  playerPortraitSprite:setCenter(0, 0)
  playerPortraitSprite:moveTo(5, 220)
end

function JamScene:initGhostPortrait()
  ghostPortraitSprite = gfx.sprite.new(ghostPortraitImage)
  ghostPortraitSprite:setCenter(0, 0)
  ghostPortraitSprite:moveTo(380, 220)
end

function JamScene:initSpeakerSprites()
  speakerLeftSprite = gfx.sprite.new(speakerImage)
  speakerRightSprite = gfx.sprite.new(speakerImage)
  speakerLeftSprite:setCenter(0.5, 0)
  speakerRightSprite:setCenter(0.5, 0)
  speakerLeftSprite:moveTo(130, 0)
  speakerRightSprite:moveTo(270, 0)
  speakerRightSprite:setImageFlip(gfx.kImageFlippedX)
end

function JamScene:initSoundwaveSprites()
  soundwaveLeftSprite = Soundwave(soundwave_imagetable, 145, 12, false)
  soundwaveRightSprite = Soundwave(soundwave_imagetable, 255, 12, true)
end

function JamScene:enter()
  self:addSprite(player)
  self:addSprite(home)
  self:addSprite(playerHealthSprite)
  self:addSprite(playerPortraitSprite)
  self:addSprite(homeHealthSprite)
  self:addSprite(ghostPortraitSprite)
  self:addSprite(speakerLeftSprite)
  self:addSprite(speakerRightSprite)
  self:addSprite(soundwaveLeftSprite)
  self:addSprite(soundwaveRightSprite)

  player:initScythe()

  local function ghostReachedHome()
    self:performHomeDamage()
  end
  local function playerWasPunched()
    self:performPlayerDamage()
  end

  victimSpawnTimer = pdtimer.new(1000)
  victimSpawnTimer.repeats = true
  victimSpawnTimer.timerEndedCallback = function(_)
    local xpos = math.random(400)
    local victim = Victim(xpos, 175, player.x, ghostReachedHome, playerWasPunched)
    victim:setZIndex(1)
    self:addSprite(victim)
  end
end

function JamScene:performHomeDamage()
  homeHealthValue = homeHealthValue + 0.3
  if homeHealthValue >= 1 then
    homeHealthSprite:setPercent(1)
    self:gameOver()
  else
    homeHealthSprite:setPercent(homeHealthValue)
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
  end,

  AButtonUp = function()
    soundwaveLeftSprite:attack()
    soundwaveRightSprite:attack()
  end
}

