require 'Tower'
require 'Map'

Menu = Class{}

local buttons = {}

menuStart = 1700
menuEnd = 1900

menuTop = 930
menuBottom = 1060

buttonSize = 140
margin = 10

upButtonX = 1730
upButtonY = 910
upButtonWidth = 140
upButtonHeight = 40

function newButton(image, fn)
    return {
        image = image,
        fn = fn
    }
end

function Menu:init()
    -- Create images for each button, start out with just the 3 towers
    self.red = love.graphics.newImage('graphics/redtower.png')
    self.green = love.graphics.newImage('graphics/greentower.png')
    self.blue = love.graphics.newImage('graphics/bluetower.png')

    self.redCost = 300
    self.greenCost = 400
    self.blueCost = 600

    self.redButtonX = 1730
    self.redButtonY = 130

    self.greenButtonX = 1730
    self.greenButtonY = 330

    self.blueButtonX = 1730
    self.blueButtonY = 530

    self.mode = 'default'

    self.ts = 0
    self.es = 0

    self.saved = 0
end

function Menu:update(dt)
    -- if a sprite is left clicked on, change the mouse mode to that tower
    -- current left click spawns tower, ideally won't spawn until placed on field
    if self.ts ~= 0 then
        self.saved = self.ts
    end
    self:upgradeTower(self.saved)
    if mB1 then
        self:spawnTower()
        
    end
    -- if the mouse is then right clicked on the menu, change the mouse to default

    -- if the mouse is then clicked on the field, check the location, then initialize that tower there
end

function Menu:render()
    -- If a button is "hot" then have it grow by 10% (rough guess)
    
    -- Drawing the contents of the right menu
    love.graphics.setFont(smallFont)

    love.graphics.draw(self.red, 1800, 200, 0, 1, 1, 70, 70)
    love.graphics.draw(self.green, 1800, 400, 0, 1, 1, 70, 70)
    love.graphics.draw(self.blue, 1800, 600, 0, 1, 1, 70, 70)

    self:displayTower()
    self:displayEnemy()
    self:upgradeButton()
    
    self:displayMessages()
    
 
    -- If player can't afford a tower, draw it black over the original button
    love.graphics.setColor(0, 0, 0, 1)
    if cash < self.redCost then
        love.graphics.draw(self.red, 1800, 200, 0, 1, 1, 70, 70)
    end
    if cash < self.greenCost then
        love.graphics.draw(self.green, 1800, 400, 0, 1, 1, 70, 70)
    end
    if cash < self.blueCost then
        love.graphics.draw(self.blue, 1800, 600, 0, 1, 1, 70, 70)
    end

    love.graphics.printf('Cash: ' .. tostring(cash), menuStart, 995, (menuEnd - menuStart), 'center')
    love.graphics.printf('Score: ' .. tostring(score), menuStart, 1040, (menuEnd - menuStart), 'center')

    love.graphics.setFont(titleFont)
    love.graphics.printf('This is TD50', menuStart, 40, (menuEnd - menuStart), 'center')

    -- Displaying the costs of the towers
    love.graphics.setFont(smallFont)
    love.graphics.printf(tostring(self.redCost), menuStart, 100, (menuEnd - menuStart), 'center')
    love.graphics.printf(tostring(self.greenCost), menuStart, 300, (menuEnd - menuStart), 'center')
    love.graphics.printf(tostring(self.blueCost), menuStart, 500, (menuEnd - menuStart), 'center')

    -- Drawing the contents of the bottom menu
    love.graphics.printf('Enemies killed: ' .. tostring(killed) .. '/' .. tostring(enemyMax), 30, menuTop, menuStart, 'left')
    love.graphics.printf('Lives left: ' .. tostring(lives), 30, menuTop + 30, menuStart, 'left')
    love.graphics.printf('Towers Built: ' .. tostring(built - 1), 30, menuTop + 60, menuStart, 'left')
    love.graphics.printf('Level: '.. tostring(level), 30, menuTop + 90, menuStart, 'left')

    love.graphics.print('F to switch fullscreen mode\nP to play/pause music\nM to mute/unmute sound effects\n2 to increase game speed', 300, 930)

    if gameState == 'levelwin' then
        love.graphics.setFont(titleFont)
        love.graphics.printf('Click anywhere to go to the next level', 0, 70, menuStart, 'center')
    end
end

-- Functions to display collections of related items
-- Separated for readability

function Menu:displayTower()
    love.graphics.push('all')
    if self.ts ~= 0 then
        love.graphics.draw(towers[self.ts].spritesheet, towers[self.ts].towersprites[towers[self.ts].sprite], 1540, menuTop - 5, 0, 2, 2)
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('Range: ' .. tostring(towers[self.ts].range), 0, menuTop, 1530, 'right')
        love.graphics.printf('Damage: ' .. tostring(towers[self.ts].damage), 0, menuTop + 30, 1530, 'right')
        love.graphics.printf('Fire Rate: ' .. tostring(towers[self.ts].fireRate), 0, menuTop + 60, 1530, 'right')
        love.graphics.printf('Cost: ' .. tostring(towers[self.ts].cost), 0, menuTop + 90, 1530, 'right')
    end
    love.graphics.pop()
end

function Menu:displayEnemy()
    love.graphics.push('all')
    if self.es ~= 0 then
        --love.graphics.draw(towers[self.ts].spritesheet, towers[self.ts].towersprites[towers[self.ts].sprite], 1560, menuTop - 5, 0, 2, 2)
        love.graphics.draw(enemies[self.es].texture, enemies[self.es].animation:getCurrentFrame(), 1270, menuTop - 5, 0, 2, 2)

        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.printf('Health: ' .. tostring(enemies[self.es].health ..'/' .. tostring(enemies[self.es].origHealth)),
        0, menuTop, 1270, 'right')
        love.graphics.printf('Speed: ' .. tostring(enemies[self.es].speed), 0, menuTop + 30, 1270, 'right')
        --love.graphics.printf('Distance Travelled: ' .. tostring(math.floor(enemies[self.es].distance)), 0, menuTop + 60, 1270, 'right')
    end
    love.graphics.pop()
end

function Menu:upgradeButton()
    love.graphics.push('all')
    if self.ts ~= 0 and cash >= towers[self.ts].cost and towers[self.ts].sprite < 7 then        
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', upButtonX, upButtonY, upButtonWidth, upButtonHeight)
        love.graphics.printf('Cost: ' .. tostring(towers[self.ts].cost), upButtonX, upButtonY + 40, upButtonWidth, 'center')
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf('Upgrade!', upButtonX, upButtonY, upButtonWidth, 'center')
        upgradeButton = true
    elseif self.ts ~= 0 and cash < towers[self.ts].cost and towers[self.ts].sprite < 7 then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle('fill', upButtonX, upButtonY, upButtonWidth, upButtonHeight)
        love.graphics.printf('Cost: ' .. tostring(towers[self.ts].cost), upButtonX, upButtonY + 40, upButtonWidth, 'center')
        upgradeButton = false
    else
        upgradeButton = false
    end
    love.graphics.pop()
end

function Menu:displayMessages()
    love.graphics.push('all')
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0, 0, 0, 1)
    if level == 1 then
        love.graphics.printf('Left click to buy a tower, right click to place it', 0, 10 * 70, menuStart, 'center')
        love.graphics.printf("Click a tower to view it's stats, and click Upgrade to improve them", 0, 11 * 70, menuStart, 'center')
    elseif level == 2 then
        love.graphics.printf('Enemy health will increase every level!', 0, 10 * 70, menuStart, 'center')
    elseif level == 3 and gameState == 'play' then
        love.graphics.printf('The blue missile launcher will deal splash damage to nearby enemies', 0, 70, menuStart, 'center')
    elseif level == 4 and gameState == 'play' then
        love.graphics.printf('Can I call this "endless mode" now?', 0, 0, menuStart, 'center')
        love.graphics.printf('Cats will now spawn enemies upon their death', 0, 70, menuStart, 'center')
    end
    love.graphics.pop()
end

function Menu:upgradeTower(towerID)
    if upgradeButton == true then
        if mX > upButtonX and mX < upButtonX + upButtonWidth and
        mY > upButtonY and mY < upButtonY + upButtonHeight and mB1 then
            cash = cash - towers[towerID].cost
            towers[towerID]:upgrade()
            towers[towerID].selected = true
            self.ts = towerID
            mB1 = false
        elseif love.keyboard.isDown('u') then
            cash = cash - towers[towerID].cost
            towers[towerID]:upgrade()
            upgradeButton = false
        end
    end    
end

function Menu:spawnTower()
    if mX > self.redButtonX and mX < self.redButtonX + buttonSize and 
        mY > self.redButtonY and mY < self.redButtonY + buttonSize then
            if self.mode == 'default' and cash >= self.redCost then
                towers[built] = Tower(mX, mY, map, 'red', built)
                self.mode = 'red'
                built = built + 1
                mB1 = false
                cash = cash - self.redCost
            end

    elseif mX > self.greenButtonX and mX < self.greenButtonX + buttonSize and 
        mY > self.greenButtonY and mY < self.greenButtonY + buttonSize then
            if self.mode == 'default' and cash >= self.greenCost then
                towers[built] = Tower(mX, mY, map, 'green', built)
                self.mode = 'green'
                built = built + 1
                mB1 = false
                cash = cash - self.greenCost
            end

    elseif mX > self.blueButtonX and mX < self.blueButtonX + buttonSize and 
        mY > self.blueButtonY and mY < self.blueButtonY + buttonSize then
            if self.mode == 'default' and cash >= self.blueCost then
                towers[built] = Tower(mX, mY, map, 'blue', built)
                self.mode = 'blue'
                built = built + 1
                mB1 = false
                cash = cash - self.blueCost
            end
    end

    if built > 1 then
        if towers[built - 1].placed == true then
            self.mode = 'default'
        end
    end
end