-- Tämä tiedosto luo yhden pelaajan koko pelin ajaksi

local player = {}

-- ======================================================================
-- PLAYER:LOAD
-- Ladataan pelaajan tiedot, sprite, animaatiot ja collider
-- world: windfield world, x, y: pelaajan aloituskoordinaatit
-- ======================================================================
function player:load(world, x, y)
    self.speed = 100

    self.spriteSheet = love.graphics.newImage('Sprites/character_animations.png')

    local anim8 = require 'Libraries.anim8'
    self.grid = anim8.newGrid(15, 23, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    -- Animaatiot
    self.animations = {
        down  = anim8.newAnimation(self.grid('1-4', 1), 0.2),
        right = anim8.newAnimation(self.grid('1-4', 2), 0.2),
        up    = anim8.newAnimation(self.grid('1-4', 3), 0.2),
        left  = anim8.newAnimation(self.grid('1-4', 4), 0.2),
    }

    -- Alustetaan pelaaja katsomaan alas
    self.anim = self.animations.down

    -- Interact cooldown
    self.interactCooldown = 0

    -- Asetetaan uusi world
    self.world = world

    -- Jos collider on jo olemassa, tuhotaan se
    if self.collider then
        self.collider:destroy()
    end


    -- Näillä voi muuttaa colliderin paikkaa
    self.colliderOffsetX = 0
    self.colliderOffsetY = 3

    -- Luodaan uusi collider
    self.collider = self.world:newBSGRectangleCollider(x + self.colliderOffsetX, y + self.colliderOffsetY, 15, 17, 1)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
end

-- ======================================================================
-- PLAYER:UPDATE
-- Liikkuminen, animaatio ja colliderin päivittäminen
-- dt: delta time
-- ======================================================================
function player:update(dt)
    local vx, vy = 0, 0
    local isMoving = false

    -- Liikkuminen näppäimillä
    if love.keyboard.isDown("up") then
        vy = -1
        self.anim = self.animations.up
        self.dir = "UP"
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = 1
        self.anim = self.animations.down
        self.dir = "DOWN"
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = -1
        self.anim = self.animations.left
        self.dir = "LEFT"
        isMoving = true
    end

    if love.keyboard.isDown("right") then
        vx = 1
        self.anim = self.animations.right
        self.dir = "RIGHT"
        isMoving = true
    end

    -- Asetetaan liike collideriin
    self.collider:setLinearVelocity(vx * self.speed, vy * self.speed)

    -- Jos ei liiku → animaation ensimmäinen frame
    if not isMoving then
        self.anim:gotoFrame(1)
    end

    -- Päivitetään pelaajan koordinaatit colliderin mukaan
    self.x = self.collider:getX() - self.colliderOffsetX
    self.y = self.collider:getY() - self.colliderOffsetY

    -- Päivitetään animaatio
    self.anim:update(dt)

    -- Interact
    if love.keyboard.isDown("space") and self.interactCooldown <= 0 then
        self:interact()
        self.interactCooldown = 0.3
    end

    if self.interactCooldown > 0 then
        self.interactCooldown = self.interactCooldown - dt
    end

    if self.interactArea then
        self.interactArea.timer = self.interactArea.timer - dt
        if self.interactArea.timer <= 0 then
            self.interactArea = nil
        end
    end
end

-- ======================================================================
-- PLAYER:DRAW
-- Piirtää pelaajan ruudulle
-- 2x skaalaus, keskitetty origin (7.5, 11.5)
-- ======================================================================
function player:draw()
    self.anim:draw(self.spriteSheet, self.x, self.y, nil, 1.5, nil, 7.5, 11.5)
end

-- Lisää pelaajan physics worldiin nykyisellä sijainnilla ilman että tilat resetoituu
function player:reAddToWorld(newWorld, x, y)
    self:load(newWorld, x or self.x, y or self.y)
end

function player:interact()
    local r = 30
    local x, y = self.x, self.y

    -- Tarkistetaan suunta
    if self.dir == "UP" then
        y = y - r
    end
    if self.dir == "DOWN" then
        y = y + r
    end
    if self.dir == "LEFT" then
        x = x - r
    end
    if self.dir == "RIGHT" then
        x = x + r
    end

    local hits = self.world:queryCircleArea(x, y, r, { "Door" })

    for _, collider in ipairs(hits) do
        if collider.object.onInteract then
            collider.object:onInteract()
        end
    end
end

return player
