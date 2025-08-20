-- Libraries
gameState = require 'Libraries.gamestate'

-- Player
player = require 'Player.player'

-- States
local town = require 'States.town'
local house = require 'States.house'

function love.load()
    -- Skaalaus, katso myöhemmin tarviiko
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- Käynnisestään peli ensimmäisessä statessa
    gameState.registerEvents()
    gameState.switch(town)
end
