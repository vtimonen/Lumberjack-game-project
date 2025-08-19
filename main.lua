function love.load()
    camera = require 'Libraries.camera'
    anim8 = require 'Libraries.anim8'
    sti = require 'Libraries.sti'
    love.graphics.setDefaultFilter("nearest", "nearest")

    gameMap = sti('Maps/testMap_2.lua')
    gameCamera = camera()


    player = {}
    player.x = 200
    player.y = 200
    player.speed = 5
    player.spriteSheet = love.graphics.newImage('Sprites/character_animations.png')

    player.grid = anim8.newGrid(15, 23, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    background = love.graphics.newImage('Sprites/back.png')
end

function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed
        player.anim = player.animations.up
        isMoving = true
    end

    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

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
    gameMap:drawLayer(gameMap.layers["Trees"])
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 2.5, nil, 7.5, 11.5)
    gameCamera:detach()
    love.graphics.print("HUD ESIMERKKI", 10, 10)
end
