local myCamera = {}
myCamera.__index = myCamera

-- ======================================================================
-- Luo uusi kamera
-- target: objekti jota kamera seuraa (pelaaja)
-- mapWidth, mapHeight: kartan koko pikseleinä
-- screenWidth, screenHeight: näytön koko pikseleinä
-- scale: zoom-kerroin (esim. 3 = 64x64 tilet)
-- ======================================================================
function myCamera:new(target, mapW, mapH, screenW, screenH, scale)
    local cam = setmetatable({}, myCamera)
    cam.target = target
    cam.mapWidth = mapW
    cam.mapHeight = mapH
    cam.screenWidth = screenW
    cam.screenHeight = screenH
    cam.scale = scale or 1
    cam.x, cam.y = target.x, target.y
    return cam
end

-- ======================================================================
-- Päivitä kameraa (seuraa pelaajaa ja rajoita kartan sisälle)
-- ======================================================================
function myCamera:update()
    local halfW = (self.screenWidth / self.scale) / 2
    local halfH = (self.screenHeight / self.scale) / 2

    local camX, camY

    -- Jos kartta on leveydeltään pienempi kuin ruutu → keskitetään
    if self.mapWidth < self.screenWidth / self.scale then
        camX = self.mapWidth / 2
    else
        camX = math.max(halfW, math.min(self.target.x, self.mapWidth - halfW))
    end

    -- Jos kartta on korkeudeltaan pienempi kuin ruutu → keskitetään
    if self.mapHeight < self.screenHeight / self.scale then
        camY = self.mapHeight / 2
    else
        camY = math.max(halfH, math.min(self.target.y, self.mapHeight - halfH))
    end

    self.x, self.y = camX, camY
end

-- ======================================================================
-- Käynnistä kamera (attach)
-- ======================================================================
function myCamera:attach()
    love.graphics.push()
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x + self.screenWidth / (2 * self.scale), -self.y + self.screenHeight / (2 * self.scale))
end

-- ======================================================================
-- Lopeta kamera (detach)
-- ======================================================================
function myCamera:detach()
    love.graphics.pop()
end

return myCamera
