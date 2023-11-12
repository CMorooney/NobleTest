local pd <const> = playdate
local gfx <const> = Graphics

Soundwave = {}
class("Soundwave").extends(AnimatedSprite)

function Soundwave:init(imagetable, x, y, flip)
  Soundwave.super.init(self, imagetable)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("idle", 1, 1, { loop = false })
  self:addState("attack",
                2,
                6,
                {
                  tickStep = 2,
                  nextAnimation = "idle",
                  onAnimationEndEvent = function()
                    self.is_attacking = false
                  end
                }
  )

  self:setCenter(0.5, 0)
  self:moveTo(x, y)

  if flip then
    self:setCollideRect(-45, 0, 75, 35)
  else
    self:setCollideRect(0, 0, 75, 35)
  end

  self:setGroups({ TAGS.Soundwave })
  self:setCollidesWithGroups({ TAGS.Ghost })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.flip = flip
  self.is_attacking = false
end

function Soundwave:update()
  Soundwave.super.update(self)

  if self.flip then
    self:setImageFlip(gfx.kImageFlippedX)
  end

  if self.is_attacking then
    local _, _, collisions, numberOfCollisions = self:checkCollisions(self.x, self.y)
    if numberOfCollisions > 0 then
      local p = collisions[1]
      local other = p.other
      other:die()
    end
  end
end

function Soundwave:attack()
  if self.is_attacking then
    return
  end

  self.is_attacking = true
  self:changeState("attack")
end

