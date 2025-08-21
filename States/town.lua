local sti = require 'Libraries.sti'
local wf = require 'Libraries.windfield'
local player = require 'Player.player'
local myCamera = require 'Libraries.myCamera'
local collisionClasses = require 'Libraries.collisionClasses'
local Door = require 'Objects.door'

local town = {}

-- ======================================================================
-- ENTER: kutsutaan kun state vaihtuu towniin
-- ======================================================================
function town:enter(spawnPoint)
    -- Ladataan kartta
    self.gameMap = sti('Maps/town.lua')

    -- Luodaan physics world
    self.world = wf.newWorld(0, 0)

    -- Ladataan collision classit
    for className, _ in pairs(collisionClasses) do
        self.world:addCollisionClass(className)
    end

    -- Ladataan pelaaja worldiin
    self.player = player

    local spawnName = type(spawnPoint)
    print("Entering town, requested spawn:", spawnName)

    local spawnX, spawnY = 90, 80 -- default

    -- Etsitään spawnPoint kartasta
    if self.gameMap.layers["Spawns"] then
        for _, obj in pairs(self.gameMap.layers["Spawns"].objects) do
            print("Spawn object:", obj.name, obj.x, obj.y)
            spawnX, spawnY = obj.x, obj.y
        end
    end

    print("Player spawn set to:", spawnX, spawnY)
    self.player:load(self.world, spawnX, spawnY)

    -- Kamera
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local mapW = self.gameMap.width * self.gameMap.tilewidth
    local mapH = self.gameMap.height * self.gameMap.tileheight
    self.gameCamera = myCamera:new(self.player, mapW, mapH, w, h, 3)


    -- Mapin seinät collidereiksi
    self.walls = {}
    if self.gameMap.layers["Walls"] then
        for _, obj in pairs(self.gameMap.layers["Walls"].objects) do
            local wall = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(self.walls, wall)
        end
    end

    -- Ladataan ovet
    self.doors = {}
    if self.gameMap.layers["Doors"] then
        for _, obj in pairs(self.gameMap.layers["Doors"].objects) do
            local doorInstance = Door:new(self.world, obj.x, obj.y, obj.width, obj.height, obj.name, obj.properties)
            table.insert(self.doors, doorInstance)
        end
    end
end

-- ======================================================================
-- UPDATE: kutsutaan jokaisessa framessa
-- dt: delta time
-- ======================================================================
function town:update(dt)
    -- Päivitetään pelaajan logiikka
    self.player:update(dt)

    -- Päivitetään physics world
    self.world:update(dt)

    -- Tämä mahdollistaa Tiledissä tehdyt animaatiot
    self.gameMap:update(dt)

    -- Päivitetään kamera
    self.gameCamera:update()

    -- door:update on tyhjä
    for _, door in pairs(self.doors) do
        door:update(dt)
    end
end

-- ======================================================================
-- DRAW: piirtää worldin, kartan ja pelaajan
-- ======================================================================
function town:draw()
    -- Kamera päälle
    self.gameCamera:attach()

    -- Piirretään taustakerrokset ensin
    if self.gameMap.layers["Background"] then
        self.gameMap:drawLayer(self.gameMap.layers["Background"])
    end

    if self.gameMap.layers["Roads"] then
        self.gameMap:drawLayer(self.gameMap.layers["Roads"])
    end

    if self.gameMap.layers["Houses"] then
        self.gameMap:drawLayer(self.gameMap.layers["Houses"])
    end

    if self.gameMap.layers["Accessories"] then
        self.gameMap:drawLayer(self.gameMap.layers["Accessories"])
    end

    -- Piirretään pelaaja
    self.player:draw()


    -- Piirretään ovet
    for _, door in pairs(self.doors) do
        door:draw()
    end

    -- Collider reunat
    -- self.world:draw()

    -- Kamera pois
    self.gameCamera:detach()

    -- Musta suorakulmio 60% opacityllä
    love.graphics.setColor(0, 0, 0, 0.6)                 -- RGBA, 0.6 = 60% opacity
    love.graphics.rectangle("fill", 5, 5, 150, 60, 4, 4) -- x, y, width, height, pyöristetyt kulmat

    love.graphics.setColor(1, 1, 1, 1)

    -- Esimerkki tekstistä ruudulla
    love.graphics.print("TOWN", 10, 10)

    -- Näytetään debug-koordinaatit
    love.graphics.setColor(1, 1, 1) -- valkoinen väri (1.0 = 255)
    love.graphics.print(
        "Player X: " .. math.floor(self.player.x) ..
        " Y: " .. math.floor(self.player.y),
        10, 30
    )

    -- Player dir
    love.graphics.print("Dir: " .. (self.player.dir or "DOWN"), 10, 50)
end

return town
