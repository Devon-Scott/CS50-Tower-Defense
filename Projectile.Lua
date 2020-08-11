Projectile = Class{}

speed = 3000

function Projectile:init(x, y, r, target, damage, type)
    self.type = type
    if self.type == 'red' then
        self.sprite = love.graphics.newImage('graphics/projectile.png')
    elseif self.type == 'green' then
        self.sprite = love.graphics.newImage('graphics/projectile2.png')
    else
        self.sprite = love.graphics.newImage('graphics/projectile3.png')
    end

    self.x = x
    self.y = y
    
    self.rotation = r

    self.dx = speed * math.sin(self.rotation)
    self.dy = (speed * math.cos(self.rotation)) * -1
    
    self.target = target
    self.damage = damage

    self.hit = 0
    self.collided = false
    self.splash = false
end

function Projectile:update(dt)
    self.y = self.y + self.dy * dt
    self.x = self.x + self.dx * dt

    self:hitEnemy()
end

function Projectile:hitEnemy()
    
    if self.x + 15 > enemies[self.target].x and self.x + 15 < enemies[self.target].x + 70 and
        self.y + 15 > enemies[self.target].y and self.y + 15 < enemies[self.target].y + 70 and self.collided == false then
            enemies[self.target].health = enemies[self.target].health - self.damage
            if self.type == 'blue' then
                self.splash = true
                for i = 1, #enemies do
                    if i ~= self.target and self:inRange(enemies[i].x + 35, enemies[i].y + 35, 125) then
                        enemies[i].health = enemies[i].health - math.floor(self.damage * 0.5)
                    end
                end
            end
            self.collided = true
    else
        -- Projectile can still hit another enemy but with less damage
        for i = 1, #enemies do
            if i ~= self.target then
                if self.x + 15 > enemies[i].x and self.x + 15 < enemies[i].x + 70 and
                    self.y + 15 > enemies[i].y and self.y + 15 < enemies[i].y + 70 and self.collided == false then
                        self.damage = math.floor(self.damage * 0.75)
                        self.hit = i
                        enemies[i].health = enemies[i].health - self.damage
                        if self.type == 'blue' then
                            self.splash = true
                            for j = 1, #enemies do
                                if self:inRange(enemies[j].x + 35, enemies[j].y + 35, 125) then
                                    enemies[j].health = enemies[j].health - math.floor(self.damage * 0.5)
                                end
                            end
                        end
                        self.collided = true
                        break
                end
            end
        end
    end
end

function Projectile:inRange(x, y, range)
    distance = math.sqrt((x - self.x) * (x - self.x) + (y - self.y) * (y - self.y))
    
    if distance <= range then
        return true
    else
        return false
    end
end

function Projectile:render()
    if self.collided == false then
        love.graphics.draw(self.sprite, self.x, self.y, self.rotation, 1, 1, 15, 15)
    end

    if self.splash == true then
        love.graphics.push('all')
        love.graphics.setColor(0, 0, 1, 0.05)
        love.graphics.circle('fill', self.x, self.y, 125)
        love.graphics.pop()
        self.splash = false
    end
end