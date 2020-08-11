-- This file checks what level is being requested, and creates the appropriate course design
-- Play area is 24x13 tiles
-- Horizontal spawns require a spawnY that is 1 less than the setTile:y value
-- Horizontal entrances/exits require a sign Y value 2 less than the entrance/exit tiles

function makeLevel(map, level)
    if level == 1 then
        for x = 1, map.mapWidth do
            map:setTile(x, math.floor(map.mapHeight / 2) + 1, 22)
        end
        startX, startY = 1, 5
        exitX, exitY = 22, 5
        spawnX, spawnY = 0, 6
    end

    if level == 2 then
        for x = 1, map.mapWidth do
            for y = 1, map.mapHeight do
                if x < map.mapWidth / 2 then
                    if y == math.floor(map.mapHeight / 3) + 1 then
                        map:setTile(x, y, 22)
                    end
                elseif y == math.floor(map.mapHeight / 3) * 2 then
                    map:setTile(x, y + 1, 22)
                end

                if x == math.floor(map.mapWidth / 2) then
                    for z = math.floor(map.mapHeight / 3), math.floor(map.mapHeight / 3) * 2 do
                        map:setTile(x, z + 1, 22)
                    end
                end
            end
        end
        startX, startY = 1, 3
        exitX, exitY = 22, 7
        spawnX, spawnY = 0, 4
    end
    
    if level >= 3 then
        for x = 1, map.mapWidth do
            for y = 1, map.mapHeight do
                if x < 21 and y == 3 then
                    map:setTile(x, y, 22)
                elseif x == 20 and y > 3 and y <= 9 then
                    map:setTile(x, y, 22)
                elseif x > 3 and x <= 14 and y == 5 then
                    map:setTile(x, y, 22)
                elseif x > 12 and x < 20 and y == 9 then
                    map:setTile(x, y, 22)
                elseif x == 14 and y > 4 and y <= 7 then
                    map:setTile(x, y, 22)
                elseif x == 13 and y >= 7 and y <= 9 then
                    map:setTile(x, y, 22)
                elseif x == 4 and y > 5 and y <= 11 then
                    map:setTile(x, y, 22)
                elseif x > 4 and y == 11 then
                    map:setTile(x, y, 22)
                end       
            end
        end
        --map:setTile(17, 7, 22)
        startX, startY = 1, 1
        exitX, exitY = 22, 9
        spawnX, spawnY = 0, 2
    end
end