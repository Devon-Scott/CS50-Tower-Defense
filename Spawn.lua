spawnTimer = 0

function spawnEnemies(map, level, dt)
    spawnTimer = spawnTimer + dt
    if level == 1 then
        if spawnTimer >= spawnTime then 
            if spawned <= enemyMax / 2 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'bat', spawned, 'right')
            elseif spawned < enemyMax - 1 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'ghost', spawned, 'right')
            elseif spawned == enemyMax - 1 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'cat', spawned, 'right')
            end
        end
    elseif level == 2 then
        if spawnTimer >= spawnTime then
            if spawned <= 10 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'snail', spawned, 'right')
            elseif spawned < 20 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'spider', spawned, 'right')
            elseif spawned < 30 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'slime', spawned, 'right')
            elseif spawned < 39 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'fly', spawned, 'right')
            elseif spawned == enemyMax - 1 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'cat', spawned, 'right')
            end
        end
    elseif level == 3 then
        if spawnTimer >= spawnTime then
            if spawned < enemyMax - 3 then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, enemyTypes[math.random(#enemyTypes)], spawned, 'right')
            elseif spawned < enemyMax then
                spawnUp()
                enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'cat', spawned, 'right')
            end
        end
    elseif level > 3 and spawnTimer > spawnTime then
        if cats < level then
            cats = cats + 1
            spawnUp()
            enemies[spawned] = Enemy(spawnX * map.tileWidth, spawnY * map.tileHeight, 'cat', spawned, 'right')
        end
    end
end

function spawnUp()
    spawned = spawned + 1
    spawnTimer = 0
end