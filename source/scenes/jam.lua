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

local victim_imagetable <const> = gfx.imagetable.new("assets/images/victim")
local ghost_imagetable <const> = gfx.imagetable.new("assets/images/ghost")
local ghostsplode_imagetable <const> = gfx.imagetable.new("assets/images/ghostsplode")

local playerHealthValue = 1
local homeHealthValue = 0

local currentWave = 1
local waveVictimsSpawned = 0
local waveVictimsKilled = 0
local waveVictimsEscaped = 0
local totalVictimsKilled = 0
local totalVictimsEscaped = 0

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
  local function ghostDied()
    self:handleGhostKill()
  end

  victimSpawnTimer = pdtimer.new(1000)
  victimSpawnTimer.repeats = true
  victimSpawnTimer.delay = 2000
  victimSpawnTimer.timerEndedCallback = function(_)
    if waveVictimsSpawned >= currentWave then return end

    local xpos = -20
    local left = math.random(2)
    if left > 1 then xpos = 420 end

    local victim = Victim(xpos,
                          175,
                          player.x,
                          victim_imagetable,
                          ghost_imagetable,
                          ghostsplode_imagetable,
                          ghostReachedHome,
                          playerWasPunched,
                          ghostDied)
    victim:setZIndex(1)
    self:addSprite(victim)
    waveVictimsSpawned = waveVictimsSpawned + 1
  end
end

function JamScene:waveIsComplete()
  if waveVictimsKilled + waveVictimsEscaped >= currentWave then
    return true
  end
  return false
end

function JamScene:nextWave()
  victimSpawnTimer:pause()
  currentWave = currentWave + 1
  waveVictimsKilled = 0
  waveVictimsSpawned = 0
  victimSpawnTimer:start()
end

function JamScene:performHomeDamage()
  homeHealthValue = homeHealthValue + 0.3
  if homeHealthValue >= 1 then
    homeHealthSprite:setPercent(1)
    self:gameOver()
  else
    homeHealthSprite:setPercent(homeHealthValue)
  end

  waveVictimsEscaped = waveVictimsEscaped + 1
  totalVictimsEscaped = totalVictimsEscaped + 1
  if self:waveIsComplete() then
    self:nextWave()
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

function JamScene:handleGhostKill()
  waveVictimsKilled = waveVictimsKilled + 1
  totalVictimsKilled = totalVictimsKilled + 1
  if self:waveIsComplete() then
    self:nextWave()
  end
end

function JamScene:gameOver()
  print("game over")
end

function JamScene:update()
  gfx.drawText("*WAVE* *" .. currentWave .. "*", 172, 220)

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

