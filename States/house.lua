local sti = require 'Libraries.sti'
local humpCamera = require 'Libraries.camera'
local wf = require 'Libraries.windfield'
local player = require 'Player.player'

local house = {}

-- ======================================================================
-- ENTER: kutsutaan kun state vaihtuu houseen
-- ======================================================================
function house:enter()
    -- Ladataan kartta
    self.gameMap = sti('Maps/house.lua') -- Huom: eri kartta

    -- Luodaan physics world
    self.world = wf.newWorld(0, 0)

    -- Ladataan pelaaja worldiin (sama pelaaja kuin townissa)
    self.player = player
    self.player:load(self.world, 0, 0) -- Esimerkki spawn-piste houseen

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
function house:update(dt)
    -- Päivitetään pelaajan logiikka
    self.player:update(dt)

    -- Päivitetään physics world
    self.world:update(dt)

    -- Kamera seuraa pelaajaa
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local mapW = self.gameMap.width * self.gameMap.tilewidth
    local mapH = self.gameMap.height * self.gameMap.tileheight

    self.gameCamera:lookAt(self.player.x, self.player.y)

    -- Kamera ei mene kartan ulkopuolelle
    if self.gameCamera.x < w / 2 then self.gameCamera.x = w / 2 end
    if self.gameCamera.y < h / 2 then self.gameCamera.y = h / 2 end
    if self.gameCamera.x > (mapW - w / 2) then self.gameCamera.x = (mapW - w / 2) end
    if self.gameCamera.y > (mapH - h / 2) then self.gameCamera.y = (mapH - h / 2) end

    -- Esimerkki: paluu town-statiin, jos pelaaja menee ovesta ulos
    if self.player.x > mapW - 50 then
        local townState = require 'States.town'
        gameState.switch(townState)
    end
end

-- ======================================================================
-- DRAW: piirtää worldin, kartan ja pelaajan
-- ======================================================================
function house:draw()
    -- Kamera päälle
    self.gameCamera:attach()

    -- Piirretään taustakerrokset
    if self.gameMap.layers["Background"] then
        self.gameMap:drawLayer(self.gameMap.layers["Background"])
    end
    if self.gameMap.layers["Matto"] then
        self.gameMap:drawLayer(self.gameMap.layers["Matto"])
    end
    if self.gameMap.layers["Jotain"] then
        self.gameMap:drawLayer(self.gameMap.layers["Jotain"])
    end
    if self.gameMap.layers["Decorations"] then
        self.gameMap:drawLayer(self.gameMap.layers["Decorations"])
    end

    -- Piirretään pelaaja
    self.player:draw()

    self.world:draw()

    -- Kamera pois
    self.gameCamera:detach()

    -- Näytetään debug-koordinaatit
    love.graphics.setColor(1, 1, 1) -- valkoinen väri (1.0 = 255)
    love.graphics.print(
        "Player X: " .. math.floor(self.player.x) ..
        " Y: " .. math.floor(self.player.y),
        10, 30
    )

    -- Teksti ruudulle esimerkkinä
    love.graphics.print("HOUSE", 10, 10)
end

return house
