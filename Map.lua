require 'Util'
require 'Enemy'
require 'Level'
require 'Tower'
require 'Spawn'

Map = Class{}

grass1 = 42
grass2 = 49

function Map:init(level)
    
    -- Creating the reference spritesheet for the border, tower area, and enemy path
    self.spritesheet = love.graphics.newImage('graphics/tilesprites.png')
    self.tileSprites = generateQuads(self.spritesheet, 70, 70)
    -- How big the tiles are in pixels
    self.tileWidth = 70
    self.tileHeight = 70

    -- Create the graphical background for the menus
    self.menu = love.graphics.newImage('graphics/menu.png')
    
    -- How many tiles wide and tall the map is
    self.mapWidth = 24
    self.mapHeight = 13

    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- A table of all the tiles that are in the finished map
    self.tiles = {}

    -- Draw the border and background
    for x = 1, self.mapWidth do
        for y = 1, self.mapHeight do
            if y == 1 or x == 1 or y == self.mapHeight or x == self.mapWidth then
                self:setTile(x, y, math.random(17, 21))
            else
                if math.random(10) == 1 then
                    self:setTile(x, y, 42)
                else
                    self:setTile(x, y, 49)
                end
            end            
        end
    end

    -- Draw the course, in Level.lua
    makeLevel(self, level)

    -- Use a timer function to spawn an enemy every x interval
    self.timer = 0
    
    spawnTime = 1
    spawnState = false

    if level == 1 then
        enemyMax = 20
    elseif level == 2 then
        enemyMax = 40
    elseif level == 3 then
        enemyMax = 60
        spawnTime = 0.5
    else
        enemyMax = level + (level * level)
        spawnTime = 0.5
    end
    
    enemyTypes = {
        'worm',
        'spider',
        'gear',
        'slime',
        'ghost',
        'snail',
        'fly',
        'bee',
        'bat'
    }
    spawned = 0
    killed = 0
    passed = 0
    cats = 0
    enemies = {}

    if level <= 3 then
        towerTypes = {
            'red',
            'green',
            'blue'
        }
        built = 1
        towers = {}
    end
end

function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:tileAt(x, y)
    return {
        x = math.floor(x / self.tileWidth) + 1,
        y = math.floor(y / self.tileHeight) + 1,
        id = self:getTile(math.floor(x / self.tileWidth) + 1, math.floor(y / self.tileHeight) + 1)
    }
end

function Map:collides(tile)
    -- define our collidable tiles
    local collidables = {
        grass1, grass2
    }

    -- iterate and return true if our tile type matches
    for _, v in ipairs(collidables) do
        if tile.id == v then
            return true
        end
    end

    return false
end

function Map:checkLives()
    if lives == 0 then
        gameState = 'loss'
    elseif killed + passed >= enemyMax and lives > 0 then
        gameState = 'levelwin'
    end   
end

function Map:update(dt)
    spawnEnemies(self, level, dt)
    
    for x = 1, #enemies do
        enemies[x]:update(dt)
    end

    for x = 1, #towers do
        towers[x]:update(dt)
    end

    self:checkLives()
end

function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            if self:getTile(x, y) ~= emptyTile then
                love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                    (x - 1) * self.tileHeight, (y - 1) * self.tileWidth)
            end
        end
    end

    -- Draw the start and end signs, locations given by makeLevel function
    love.graphics.draw(self.spritesheet, self.tileSprites[53], (startX) * self.tileWidth, (startY) * self.tileHeight)
    love.graphics.draw(self.spritesheet, self.tileSprites[55], (exitX) * self.tileWidth, (exitY) * self.tileHeight)
    
    for x = 1, #enemies do
        enemies[x]:render()
    end

    for x = 1, #towers do
        towers[x]:render()
    end

    love.graphics.draw(self.menu, 0, 0)
end