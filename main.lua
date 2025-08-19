function love.load()
    camera = require 'Libraries.camera'
    anim8 = require 'Libraries.anim8'
    sti = require 'Libraries.sti'
    wf = require 'Libraries.windfield'
    love.graphics.setDefaultFilter("nearest", "nearest")

    gameMap = sti('Maps/colliderTest.lua')
    gameCamera = camera()
    world = wf.newWorld(0, 0)


    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 20, 40, 7)
    player.collider:setFixedRotation(true)
    player.x = 200
    player.y = 200
    player.speed = 150
    player.spriteSheet = love.graphics.newImage('Sprites/character_animations.png')

    player.grid = anim8.newGrid(15, 23, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    background = love.graphics.newImage('Sprites/back.png')

    walls = {}
    if gameMap.layers["Walls"] then
        for i, obj in pairs(gameMap.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end
end

function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("up") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    gameCamera:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()


    -- Estää kameran liikkumisen kun vasen reuna saavutettu
    if gameCamera.x < w / 2 then
        gameCamera.x = w / 2
    end

    -- Estää kameran liikkumisen kun yläreuna saavutettu
    if gameCamera.y < h / 2 then
        gameCamera.y = h / 2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- Oikea reuna
    if gameCamera.x > (mapW - w / 2) then
        gameCamera.x = (mapW - w / 2)
    end

    -- Alareuna
    if gameCamera.y > (mapH - h / 2) then
        gameCamera.y = (mapH - h / 2)
    end
end

function love.draw()
    gameCamera:attach()
    gameMap:drawLayer(gameMap.layers["Ground"])
    gameMap:drawLayer(gameMap.layers["Road"])
    gameMap:drawLayer(gameMap.layers["Houses"])
    gameMap:drawLayer(gameMap.layers["Rocks"])
    -- ehkä objekti
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2, nil, 7.5, 11.5)
    world:draw()
    gameCamera:detach()
    love.graphics.print("HUD ESIMERKKI", 10, 10)
end
