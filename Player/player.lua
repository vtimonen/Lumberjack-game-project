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

    -- Asetetaan uusi world
    self.world = world

    -- Jos collider on jo olemassa, tuhotaan se
    if self.collider then
        self.collider:destroy()
    end

    -- Luodaan uusi collider
    self.collider = self.world:newBSGRectangleCollider(x, y, 20, 40, 7)
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
    self.x = self.collider:getX()
    self.y = self.collider:getY()

    -- Päivitetään animaatio
    self.anim:update(dt)
end

-- ======================================================================
-- PLAYER:DRAW
-- Piirtää pelaajan ruudulle
-- 2x skaalaus, keskitetty origin (7.5, 11.5)
-- ======================================================================
function player:draw()
    self.anim:draw(self.spriteSheet, self.x, self.y, nil, 2, nil, 7.5, 11.5)
end

-- Lisää pelaajan physics worldiin nykyisellä sijainnilla ilman että tilat resetoituu
function player:reAddToWorld(newWorld, x, y)
    self:load(newWorld, x or self.x, y or self.y)
end

return player
