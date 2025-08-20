-- Libraries/transition.lua
local Transition = {}
Transition.__index = Transition

function Transition:new()
    local obj = {
        active = false,
        alpha = 0, -- Läpinäkyvyys, 0 = näkyvä, 1 = musta
        speed = 2, -- Fade nopeus
        fadeOutDone = nil,
        fadeInDone = nil,
        nextState = nil,
        phase = "idle" -- idle / fadeOut / fadeIn
    }
    setmetatable(obj, self)
    return obj
end

-- Aloita transition
-- nextState: state moduuli joka ladataan fade-outin jälkeen
-- speed: fade nopeus (valinnainen)
function Transition:start(nextState, speed, fadeOutDone, fadeInDone)
    if self.active then return end
    self.active = true
    self.nextState = nextState
    self.alpha = 0
    self.speed = speed or 2
    self.phase = "fadeOut"
    self.fadeOutDone = fadeOutDone
    self.fadeInDone = fadeInDone
end

-- Päivitetään jokaisessa framessa
function Transition:update(dt)
    if not self.active then return end

    if self.phase == "fadeOut" then
        self.alpha = self.alpha + self.speed * dt
        if self.alpha >= 1 then
            self.alpha = 1
            -- Fade-out valmis, vaihdetaan state
            if type(self.nextState) == "function" then
                self.nextState() -- Voidaan antaa callback tai gameState.switch(...)
            else
                local gameState = require("gameState")
                gameState.switch(self.nextState)
            end
            if self.fadeOutDone then self.fadeOutDone() end
            self.phase = "fadeIn"
        end
    elseif self.phase == "fadeIn" then
        self.alpha = self.alpha - self.speed * dt
        if self.alpha <= 0 then
            self.alpha = 0
            self.phase = "idle"
            self.active = false
            if self.fadeInDone then self.fadeInDone() end
        end
    end
end

-- Piirretään fade
function Transition:draw()
    if self.active then
        love.graphics.setColor(0, 0, 0, self.alpha)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Transition
