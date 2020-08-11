require 'Util'
require 'Animation'
require 'Spawn'

Enemy = Class{}

function Enemy:init(x, y, type, id, direction)
    self.texture = love.graphics.newImage('graphics/enemysprites.png')
    self.width = 70
    self.height = 70
    self.frames = generateQuads(self.texture, self.width, self.height)

    self.id = id

    self.xOffset = self.width / 2
    self.yOffset = self.height / 2

    self.map = map
    self.distance = 0

    self.x = x
    self.y = y

    self.type = type
    self.animations = {
        ['worm'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[1], self.frames[2]
            },
            interval = .3
        },
        ['spider'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[9], self.frames[7], self.frames[9], self.frames[8]
            },
            interval = .2
        },
        ['gear'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[4], self.frames[5]
            },
            interval = .1
        },
        ['slime'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[11], self.frames[12]
            },
            interval = .4
        },
        ['ghost'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[19], self.frames[20]
            },
            interval = .7
        },
        ['snail'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[13], self.frames[14]
            },
            interval = .4
        },
        ['fly'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[25], self.frames[26]
            },
            interval = .04
        },
        ['bee'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[31], self.frames[32]
            },
            interval = .03
        },
        ['bat'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[34], self.frames[35]
            },
            interval = .3
        },
        ['cat'] = Animation {
            texture = self.texture,
            frames = {
                self.frames[17]
            },
            interval = .3
        }
    }
    self.animation = self.animations[self.type]

    if self.type == 'worm' then
        self.speed = 45
        self.health = 255
    elseif self.type == 'spider' then
        self.speed = 75
        self.health = 225
    elseif self.type == 'gear' then
        self.speed = 105
        self.health = 195
    elseif self.type == 'slime' then
        self.speed = 135
        self.health = 165
    elseif self.type == 'ghost' then
        self.speed = 120
        self.health = 180
    elseif self.type == 'snail' then    
        self.speed = 105
        self.health = 195
    elseif self.type == 'fly' then
        self.speed = 150
        self.health = 150
    elseif self.type == 'bee' then
        self.speed = 180
        self.health = 120
    elseif self.type == 'bat' then
        self.speed = 90
        self.health = 210
    elseif self.type == 'cat' then
        self.speed = 80
        self.health = 2000
    end

    if level < 10 then
        self.health = self.health * level
    else
        self.health = self.health * (level + (level - 9)) 
    end
    
    self.origHealth = self.health
    
    self.direction = direction
    self.behaviours = {
        ['worm'] = function(dt)
            
        end,
        ['spider'] = function(dt)
            
        end,
        ['gear'] = function(dt)
            
        end,
        -- Changes the speed depending on what frame of the animation it's at
        ['slime'] = function(dt)
            if self.animation:getCurrentFrame() == self.frames[12] then
                self.speed = 20
            else
                self.speed = 135
            end
            
        end,
        ['ghost'] = function(dt)
            
        end,
        ['snail'] = function(dt)
            if self.animation:getCurrentFrame() == self.frames[13] then
                self.speed = 105
            else
                self.speed = 15
            end
        end,
        ['fly'] = function(dt)
            
        end,
        ['bee'] = function(dt)
            
        end,
        ['bat'] = function(dt)
            
        end,
        ['cat'] = function(dt)

        end
    }
    
    self.dx = 0
    self.dy = 0
    self.state = 'alive'
    self.selected = false
end

function Enemy:update(dt)
    if self.state ~= 'dead' then
        self.behaviours[self.type](dt)
        self:collision()
        self:directions()
        self:checkLife()
        self:clicked()
        
        self.animation:update(dt)
        self.y = self.y + self.dy * dt
        self.x = self.x + self.dx * dt
        self.distance = self.distance + (self.dx * dt) + (self.dy * dt)
    end
end

function Enemy:mouseOnSprite()
    if mX > self.x and mX < self.x + self.width 
    and mY > self.y and mY < self.y + self.height then
        return true
    else 
        return false
    end
end

function Enemy:clicked()
    -- if the tower is left clicked, select the tower
    if mB1 then
        if self:mouseOnSprite() then
            self.selected = true            
            menu.es = self.id
        else
            self.selected = false
            if menu.es == self.id and menu.ts == 0 then
                menu.es = 0
            end
        end
    end
end

function Enemy:checkLife()
    if self.health <= 0 then
        if self.type == 'cat' then
            if level > 3 then
                for x = 1, level do
                    spawned = spawned + 1
                    enemies[spawned] = Enemy(self.x, self.y, enemyTypes[math.random(#enemyTypes)], spawned, self.direction)                
                end
            end
            cat:seek(0.05, 'seconds')
            if not muteEffects then
                cat:setVolume(0.4)
                cat:play()
            end
        end
        self.state = 'dead'
        self.x = 0
        self.y = 0
        self.dx = 0
        self.dy = 0
        self.speed = 0
        killed = killed + 1
        score = score + 1
        cash = cash + 40

        if menu.es == self.id then
            menu.es = 0
        end

    elseif self.x >= map.mapWidthPixels or self.y > map.mapHeightPixels then
        self.state = 'dead'
        self.x = 0
        self.y = 0
        self.dx = 0
        self.dy = 0
        self.speed = 0
        if self.type ~= 'cat' then
            lives = lives - 1
        elseif lives == 1 then
            lives = 0
        else
            lives = 1
        end
        passed = passed + 1
        if menu.es == self.id then
            menu.es = 0
        end
    end
end

function Enemy:directions()
    if self.direction == 'right' then        
        self.dx = self.speed
    elseif self.direction == 'left' then        
        self.dx = -self.speed
    elseif self.direction == 'down' then        
        self.dy = self.speed
    elseif self.direction == 'up' then        
        self.dy = -self.speed
    end
end

function Enemy:collision()
    -- Checks for right collision and decides where to go
    if self.dx > 0 and self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.yOffset)) then
        self.dx = 0
        self.x = (self.map:tileAt(self.x + self.width, self.y).x - 1) * self.map.tileWidth - self.width
        if self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y - 1)) then
            self.direction = 'down'
        elseif self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y + self.height + 1)) then
            self.direction = 'up'
        end
    end 
    
    -- Checks for left collision and decides where to go
    if self.dx < 0 and self.map:collides(self.map:tileAt(self.x, self.y + self.yOffset)) then
        self.dx = 0
        self.x = self.map:tileAt(self.x - 1, self.y).x * self.map.tileWidth
        if self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y - 1)) then
            self.direction = 'down'
        elseif self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y + self.height + 1)) then
            self.direction = 'up'
        end
    end

    -- Checks for bottom collision
    if self.dy > 0 and self.map:collides(self.map:tileAt(self.x + self.xOffset, self.y + self.height)) then
        self.dy = 0
        self.y = (self.map:tileAt(self.x, self.y + self.height).y - 1) * self.map.tileHeight - self.height
        if self.map:collides(self.map:tileAt(self.x + self.width + 1, self.y + self.yOffset)) then
            self.direction = 'left'
        elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.yOffset)) then
            self.direction = 'right'
        end
    end

    -- Checks for top collision
    if self.dy < 0 and self.map:collides(self.map:tileAt(self.x + self.xOffset, self. y)) then
        self.dy = 0
        self.y = self.map:tileAt(self.x, self.y - 1).y * self.map.tileHeight
        if self.map:collides(self.map:tileAt(self.x + self.width + 1, self.y + self.yOffset)) then
            self.direction = 'left'
        elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.yOffset)) then
            self.direction = 'right'
        end
    end
end

function Enemy:render()
    if self.state == 'alive' then
        local scaleX
        if self.direction == 'right' then
            scaleX = -1
        else
            scaleX = 1
        end
        love.graphics.draw(self.texture, self.animation:getCurrentFrame(),
            math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2),
            0, scaleX, 1, self.xOffset, self.yOffset)

        love.graphics.push('all')
        love.graphics.setFont(healthFont)
        if self.type ~= 'ghost' then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0, 0, 0, 1)
        end
        love.graphics.printf(tostring(self.health), self.x - 30, self.y + 42, 130, 'center')
        love.graphics.pop()
    end
end