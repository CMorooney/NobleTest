local pd <const> = playdate
local gfx <const> = Graphics

Scythe = {}
class("Scythe").extends(AnimatedSprite)

local scythe_imagetable <const> = gfx.imagetable.new("assets/images/scythe")

function Scythe:init(x, y)
  Scythe.super.init(self, scythe_imagetable)

  self:remove() -- AnimatedSprite adds itself to the scene but we want to manage that through Noble

  self:addState("attack",
                1,
                9,
                {
                  tickStep = 1,
                  loop = false,
                  onAnimationEndEvent = function()
                    self.is_attacking = false
                    self:setVisible(false)
                  end
                }
  )

  self:moveTo(x, y)

  self:setCollideRect(0, 0, 75, 75)
  self:setGroups({ 3 })
  self:setCollidesWithGroups({ 2 })
  self.collisionResponse = gfx.sprite.kCollisionTypeOverlap

  self.facing_right = false
  self.is_attacking = false
end

function Scythe:update()
  Scythe.super.update(self)

  if self.facing_right then
    self:setImageFlip(gfx.kImageUnflipped)
  else
    self:setImageFlip(gfx.kImageFlippedX)
  end

  if self.is_attacking then
    local _, _, collisions, numberOfCollisions = self:checkCollisions(self.x, self.y)
    if numberOfCollisions > 0 then
      local p = collisions[1]
      local other = p.other
      if self.facing_right ~= other.facing_right and self:alphaCollision(other) then
        other:die()
      end
    end
  end
end

function Scythe:attack()
  if self.is_attacking then
    return
  end

  self.is_attacking = true
  self:setVisible(true)
  self:playAnimation()
end

