require 'Util'
require 'Projectile'

Tower = Class{}

function Tower:init(x, y, map, type, id)

    self.spritesheet = love.graphics.newImage('graphics/towersprites.png')
    self.towersprites = generateQuads(self.spritesheet, 70, 70)

    self.id = id
    -- Properties that should change depending on type
    if type == 'red' then
        self.type = 'red'
        self.sprite = 1
        self.range = 200
        self.damage = 25
        self.fireRate = 3
        self.cost = 200
        self.sound = love.audio.newSource('sounds/redShot.wav', 'static')
    elseif type == 'green' then
        self.type = 'green'
        self.sprite = 2
        self.range = 175
        self.damage = 10
        self.fireRate = 10
        self.cost = 400
        self.sound = love.audio.newSource('sounds/greenShot.wav', 'static')
    elseif type == 'blue' then
        self.type = 'blue'
        self.sprite = 3
        self.range = 300
        self.damage = 60
        self.fireRate = 1
        self.cost = 600
        self.sound = love.audio.newSource('sounds/blueShot.wav', 'static')
    end

    self.sound:setVolume(0.2)
    self.stage = 1

    self.timer = 0
    
    self.xOffset = 35
    self.yOffset = 35
    self.x = (x - 1) * map.tileWidth - self.xOffset
    self.y = (y - 1) * map.tileHeight - self.yOffset
    self.width = 70
    self.height = 70

    self.centerX = self.x + self.xOffset
    self.centerY = self.y + self.yOffset

    self.rotation = math.rad(0)

    self.target = 0
    self.targetX = 0
    self.targetY = 0

    self.fired = 1

    self.projectiles = {}

    self.placed = false
    self.selected = false
    self.moving = true
end

function Tower:upgrade()
    if self.sprite < 7 then
        self.sprite = self.sprite + 3
    end
    self.range = math.ceil(self.range * 1.5)
    self.damage = math.ceil(self.damage * 1.5)
    self.fireRate = math.ceil(self.fireRate * 1.5)
    self.cost = self.cost * 2
    self.stage = self.stage + 1
end

function Tower:getTarget()
    -- Checks to see if the existing target is out of range
    if self.target ~= 0 and enemies[self.target].state == 'alive' then
        if not self:inRange(enemies[self.target].x + 35, enemies[self.target].y + 35, self.range) then
            self.target = 0
        end
    end
    
    -- Gets a new target, or updates the coordinates of the existing target
    if self.target == 0 or enemies[self.target].state == 'dead' then
        for i = 1, #enemies do
            if self:inRange(enemies[i].x + 35, enemies[i].y + 35, self.range) and enemies[i].state == 'alive' then
                self.target = i
                self.targetX = enemies[i].x + 35
                self.targetY = enemies[i].y + 35
                break
            end
        end
    else
        self.targetX = enemies[self.target].x + 35
        self.targetY = enemies[self.target].y + 35
    end

    -- Updates the rotation to aim at the target, and resets to neutral if there is no target
    if self.target ~= 0 and enemies[self.target].state == 'alive'  then
        self.rotation = self:getAngle(self.x, self.y, self.targetX, self.targetY)
    else
        self.rotation = math.rad(0)
    end
end

function Tower:getAngle(x, y, targetX, targetY)
    return (math.atan2(targetY - y, targetX - x)) + math.rad(90)
end

function Tower:inRange(x, y, range)
    distance = math.sqrt((x - self.x) * (x - self.x) + (y - self.y) * (y - self.y))
    
    if distance <= range then
        return true
    else
        return false
    end
end

function Tower:fire()
    if self.target ~= 0 and enemies[self.target].state == 'alive' then
        self.projectiles[self.fired] = Projectile(self.x, self.y, self.rotation, self.target, self.damage, self.type)
        self.fired = self.fired + 1
        self.sound:seek(0, "seconds")
        if not muteEffects then
            if self.type == 'blue' then
                self.sound:setVolume(0.12)
            else
                self.sound:setVolume(0.08)
            end
            self.sound:play()
        else
            self.sound:setVolume(0)
        end
        if self.fired == 10 then
            self.fired = 1
        end
    end
end

function Tower:mouseOnSprite()
    if mX > self.x - self.xOffset and mX < self.x + self.width - self.xOffset 
    and mY > self.y - self.yOffset and mY < self.y + self.height - self.yOffset then
        return true
    else 
        return false
    end
end

function Tower:clicked()
    -- if the tower is left clicked, select the tower
    if mB1 then
        if self:mouseOnSprite() then
            self.selected = true            
            menu.ts = self.id
        else
            self.selected = false
            if menu.ts == self.id and menu.es == 0 then
                menu.ts = 0
            end
        end
    end

    if mB2 then
        -- if the tower is right clicked, pick up the tower
        if self:mouseOnSprite() and not self.moving then
            self.moving = true
            mB2 = false

        -- if the tower is right clicked while being moved, drop the tower at that tile, if it's a grass tile
        elseif self.moving and map:collides(map:tileAt(mX, mY)) then
            self.x = ((math.floor(mX / map.tileHeight) + 1) * map.tileWidth - self.xOffset)
            self.y = ((math.floor(mY / map.tileWidth) + 1) * map.tileHeight - self.yOffset)
            self.moving = false
            self.placed = true
            mB2 = false
        end

        -- if an enemy is right clicked while the tower is selected, that's the new target
        if self.selected then
            for x = 1, #enemies do
                if mX > enemies[x].x and mX < enemies[x].x + 70 and mY > enemies[x].y and mY < enemies[x].y + 70 and
                self:inRange(enemies[x].x, enemies[x].y, self.range) then
                    self.target = x
                    break
                end
            end
        end
    end
end

function Tower:update(dt)

    self:getTarget()
    self:clicked()

    self.timer = self.timer + dt

    if self.placed and not self.moving then
        self.fireTime = 1 / self.fireRate
        if self.timer >= self.fireTime then
            self:fire()
            self.timer = 0
        end

        if self.fired > 1 then
            for x = 1, #self.projectiles do
                self.projectiles[x]:update(dt)
            end
        end
    else
        self.x = mX
        self.y = mY
    end
    
end

function Tower:render()
    -- Draw a circle to visualize the range of the tower
    if self.selected or self.moving then
        love.graphics.circle('line', self.x, self.y, self.range) 
    end
    
    

    love.graphics.draw(self.spritesheet, self.towersprites[self.sprite], self.x, self.y, self.rotation, 1, 1, self.xOffset, self.yOffset)

    if self.fired > 1 then
        for x = 1, #self.projectiles do
            self.projectiles[x]:render()
        end
    end
end