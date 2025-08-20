local sti = require 'Libraries.sti'
local wf = require 'Libraries.windfield'
local player = require 'Player.player'
local myCamera = require 'Libraries.myCamera'

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
    self.player:load(self.world, 390, 47) -- Esimerkki spawn-piste houseen

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

    -- Päivitetään kamera
    self.gameCamera:update()

    -- Kartan koko pikseleinä (tilejen määrä * tilejen koko)
    local mapW = self.gameMap.width * self.gameMap.tilewidth
    local mapH = self.gameMap.height * self.gameMap.tileheight

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
        self.gameMap:drawLayer(self.gameMap.layers["Background"], 0, 0, 10, 10)
    end
    if self.gameMap.layers["Matto"] then
        self.gameMap:drawLayer(self.gameMap.layers["Matto"], 0, 0, 10, 10)
    end
    if self.gameMap.layers["Jotain"] then
        self.gameMap:drawLayer(self.gameMap.layers["Jotain"], 0, 0, 10, 10)
    end
    if self.gameMap.layers["Decorations"] then
        self.gameMap:drawLayer(self.gameMap.layers["Decorations"], 0, 0, 10, 10)
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

    -- Teksti ruudulle esimerkkinä
    love.graphics.print("HOUSE", 10, 10)

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

return house
