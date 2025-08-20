local sti = require 'Libraries.sti'
local humpCamera = require 'Libraries.camera'
local wf = require 'Libraries.windfield'
local player = require 'Player.player'

local town = {}

-- ======================================================================
-- ENTER: kutsutaan kun state vaihtuu towniin
-- ======================================================================
function town:enter()
    -- Ladataan kartta
    self.gameMap = sti('Maps/town.lua')

    -- Luodaan physics world
    self.world = wf.newWorld(0, 0)

    -- Ladataan pelaaja worldiin
    self.player = player
    self.player:load(self.world, 200, 200)

    -- Ladataan pelaaja worldiin vain jos ei ole vielä ladattu
    if not self.player.loaded then
        self.player:load(self.world, 200, 200)
        self.player.loaded = true
    else
        -- Pelaaja siirretään worldiin nykyisellä sijainnillaan
        self.player:reAddToWorld(self.world)
    end

    -- Kamera
    self.gameCamera = humpCamera(self.player.x, self.player.y)


    -- Mapin seinät collidereiksi
    self.walls = {}
    if self.gameMap.layers["Walls"] then
        for _, obj in pairs(self.gameMap.layers["Walls"].objects) do
            local wall = self.world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(self.walls, wall)
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

    -- Päivitetään world
    self.world:update(dt)

    -- Kamera seuraa pelaajaa
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mapW = self.gameMap.width * self.gameMap.tilewidth
    local mapH = self.gameMap.height * self.gameMap.tileheight

    self.gameCamera:lookAt(self.player.x, self.player.y)

    -- Kamera lopettaa liikkumisen kun saavutetaan kartan reuna(t)
    if self.gameCamera.x < w / 2 then self.gameCamera.x = w / 2 end
    if self.gameCamera.y < h / 2 then self.gameCamera.y = h / 2 end
    if self.gameCamera.x > (mapW - w / 2) then self.gameCamera.x = (mapW - w / 2) end
    if self.gameCamera.y > (mapH - h / 2) then self.gameCamera.y = (mapH - h / 2) end

    -- Esimerkki: siirtyminen house-statiin kun pelaaja menee kartan vasemmalta reunalta
    if self.player.x and self.player.x < 50 then
        local houseState = require 'States.house'
        gameState.switch(houseState)
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

    self.world:draw()

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
