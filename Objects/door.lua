local Door = {}
Door.__index = Door

-- ======================================================================
-- Luo uusi ovi
-- world: physics world
-- x, y: sijainti
-- width, height: koko
-- name: oven nimi (tämä määrittää interaktion)
-- props: lisäominaisuudet Tiledistä (targetState, targetSpawn)
-- ======================================================================
function Door:new(world, x, y, width, height, name, props)
    local door = setmetatable({}, Door)
    door.name = name or "Door"
    door.props = props or {}

    -- Tallennetaan mikä state ja mikä spawnpoint
    door.targetState = door.props.targetState
    door.targetSpawn = door.props.targetSpawn

    -- Tulostus kaikista kartan ovista jne.
    print("Door created:", door.name, "targetState:", door.targetState, "targetSpawn:", door.targetSpawn,
        type(door.targetSpawn))

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
    if self.targetState and self.targetSpawn then
        print("Going to state: " .. self.targetState .. " at spawn: " .. self.targetSpawn)
        gameState.switch(require("States." .. self.targetState), self.targetSpawn)
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
