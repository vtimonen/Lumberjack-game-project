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
    self.player:load(self.world, 400, 67) -- Esimerkki spawn-piste houseen

    -- Kamera
    self.gameCamera = humpCamera(self.player.x, self.player.y)
    self.gameCamera.scale = 4 -- nelinkertainen skaalaus

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

    -- Haetaan ruudun leveys ja korkeus pikseleinä
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- Kartan koko pikseleinä (tilejen määrä * tilejen koko)
    local mapW = self.gameMap.width * self.gameMap.tilewidth
    local mapH = self.gameMap.height * self.gameMap.tileheight

    -- Zoom-kerroin, eli kuinka paljon kameraa on skaalattu
    local camScale = 4

    -- Lasketaan kuinka paljon näytettävä alue kattaa karttaa kameran mittakaavassa
    local halfW = (w / camScale) / 2
    local halfH = (h / camScale) / 2

    -- Nyt rajoitetaan kamera niin, ettei se mene kartan ulkopuolelle:
    -- math.max(halfW, ...) varmistaa, ettei kamera mene vasemman yläreunan yli
    -- math.min(..., mapW - halfW) varmistaa, ettei kamera mene oikean alareunan yli
    -- Sama logiikka y-koordinaatille
    local camX = math.max(halfW, math.min(self.player.x, mapW - halfW))
    local camY = math.max(halfH, math.min(self.player.y, mapH - halfH))

    self.gameCamera:lookAt(camX, camY)

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
