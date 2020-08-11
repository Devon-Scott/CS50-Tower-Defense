-- Graphical assets created by Kenney.nl https://opengameart.org/content/platformer-art-deluxe
-- Tower and projectile art by Nido https://opengameart.org/content/tower-defence-basic-towers
-- Dimbo font by Jayvee Enaguas https://www.dafont.com/dimbo.font

-- Background music by blockh34d https://freesound.org/s/385984/

-- Background music 2 by envirOmaniac2 https://freesound.org/s/398941/
-- Red shot sound effect by Isaac200000 https://freesound.org/s/184650/
-- Green shot sound effect by okieactor https://freesound.org/s/415912/
-- Blue shot sound effect by V-ktor https://freesound.org/s/435413/
-- Cat sound effect by skymary https://freesound.org/s/412017/

-- Portions of code have been copied or adapted from the CS50x games track
-- More detail in the README.md file

Class = require 'class'
push = require 'push'

require 'Map'
require 'Menu'

WINDOW_WIDTH = 1920
WINDOW_HEIGHT = 1080

VIRTUAL_WIDTH = 1920
VIRTUAL_HEIGHT = 1080

STARTCASH = 2000

function love.load()
    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
    mX, mY = love.mouse.getPosition()

    love.window.setTitle('Tower Defense 50')

    healthFont = love.graphics.newFont('fonts/Dimbo.ttf', 18)
    smallFont = love.graphics.newFont('fonts/Dimbo.ttf', 25)
    titleFont = love.graphics.newFont('fonts/Dimbo.ttf', 45)
    bigFont = love.graphics.newFont('fonts/Dimbo.ttf', 250)
    love.graphics.setFont(titleFont)
    
    music = love.audio.newSource('sounds/bgMusic2.wav', 'static')
    cat = love.audio.newSource('sounds/catMeow.wav', 'static')
    
    music:setLooping(true)
    music:setVolume(0.15)
    music:play()

    muteEffects = false

    lives = 3
    level = 1
    cash = STARTCASH
    map = Map(level)
    menu = Menu()

    gameState = 'loss'
    upgradeButton = false
    
    towerTypes = {
        'red',
        'green',
        'blue'
    }
    built = 1
    towers = {}

    score = 0
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'f' then
        push:switchFullscreen(WINDOW_WIDTH, WINDOW_HEIGHT)
    end

    if key == 'n' then
        love.event.quit('restart')
    end

    if key == 'p' then
        if music:isPlaying() then
            music:pause()
        else
            music:play()
        end
    end

    if key == 'm' then
        muteEffects = true
    end    
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mB1 = true
    end

    if button == 2 then
        mB2 = true
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        mB1 = false
    end

    if button == 2 then
        mB2 = false
    end
end

function love.update(dt)
    mX, mY = push:toGame(love.mouse.getPosition())
    
    if gameState == 'play' then
        if love.keyboard.isDown('2') then
            dt = love.timer.getDelta() * 2
        end

        if love.keyboard.isDown('1') then
            dt = 0
        end
        
        map:update(dt)
        menu:update(dt)
    elseif gameState == 'loss' then
        if music:isPlaying() then
            music:pause()
        end
        if mB1 then
            lives = 3
            level = 1
            cash = STARTCASH
            map = Map(level)
            menu = Menu()
            built = 1
            towers = {}
            score = 0
            gameState = 'play'
            upgradeButton = false
        end
    elseif gameState == 'levelwin' then
        if mB1 then
            gameState = 'next'
        else
            map:update(dt)
            menu:update(dt)
        end
    elseif gameState == 'next' then
        for x = 1, #towers do
            if level < 3 then
                cash = cash + (towers[x].cost)
            end
            towers[x].target = 0
            towers[x].projectiles = {}
            towers[x].fired = 1
        end
        level = level + 1
        lives = lives + 1
        map = Map(level)
        menu.ts = 0
        menu.es = 0
        gameState = 'play'
    end
end

function love.draw()
    push:apply('start')
    if gameState == 'play' or gameState == 'levelwin' then
        
        love.graphics.clear(0, 0, 0)

        map:render()
        menu:render()
        
    elseif gameState == 'loss' then
        love.graphics.clear(0, 0, 0)
        love.graphics.setFont(bigFont)
        love.graphics.printf('Game Over', 0, (VIRTUAL_HEIGHT / 2) - (bigFont:getHeight() / 2), VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(titleFont)
        love.graphics.printf('Click anywhere to play again', 0, (VIRTUAL_HEIGHT / 2) + (bigFont:getHeight() / 2), VIRTUAL_WIDTH, 'center')
        
    end
    push:apply('end')
end