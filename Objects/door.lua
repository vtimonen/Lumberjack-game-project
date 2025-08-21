local Door = {}
Door.__index = Door

-- ======================================================================
-- Luo uusi ovi
-- world: physics world
-- x, y: sijainti
-- width, height: koko
-- name: oven nimi (tämä määrittää interaktion)
-- ======================================================================
function Door:new(world, x, y, width, height, name)
    local door = setmetatable({}, Door)
    door.name = name or "Door"

    -- luodaan collider physics worldiin
    door.collider = world:newRectangleCollider(x, y, width, height)
    door.collider:setType('static')
    door.collider:setCollisionClass("Door")

    -- liitetään olio collideriin (mahdollistaa collision callbackit)
    door.collider:setObject(door)

    return door
end

-- ======================================================================
-- Pelaaja käyttää ovea
-- ======================================================================
function Door:onInteract()
    if self.name == "HouseDoor" then
        print("Going inside the house...")
        gameState.switch(require("States.house"))
    elseif self.name == "CastleDoor" then
        print("Entering the castle...")
        gameState.switch(require("States.castle"))
    else
        print("This door does nothing.")
    end
end

-- ======================================================================
-- Päivitä ovi (esim. animaatiot tulevaisuudessa)
-- ======================================================================
function Door:update(dt)
    -- tyhjä, mutta voidaan lisätä animaatioita tai tms.
end

-- ======================================================================
-- Piirrä ovi (esim. debug-visualisointi)
-- ======================================================================
function Door:draw()
    -- Jos halutaan näkyvä debug-visualisointi
    -- love.graphics.setColor(1, 0, 0, 0.5)
    -- local x, y = self.collider:getPosition()
    -- local w, h = self.collider:getShape():getDimensions()
    -- love.graphics.rectangle("fill", x - w/2, y - h/2, w, h)
    -- love.graphics.setColor(1, 1, 1, 1)
end

return Door
