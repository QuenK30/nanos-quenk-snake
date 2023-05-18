--[[
    Project: "NanosSnake"
    Date: 14.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--
Package.Require("Config.lua")

-- create table for timer
TimeFood = {
    name,
    time
}

function createFood(x, y, z)
    local food = StaticMesh(Vector(x,y,z), Rotator(), "snake::SM_Mushroom")
    food:SetValue("IsFood", true)
end

function spawnFood()
    local map_size = Vector(MAP_SIZE, MAP_SIZE, MAP_SIZE)
    local randomX = math.random(-map_size.X / 2, map_size.X / 2)
    local randomY = math.random(-map_size.Y / 2, map_size.Y / 2)
    createFood(randomX, randomY, 0)
end

function randomSpawnFood(player)
    local randomTime = math.random(2, 6)
    local T = Timer.SetTimeout(spawnFood, randomTime * 1000)
    TimeFood.name = player:GetName()
    TimeFood.time = T
end

function stopTimerFood()
    for _, player in pairs(Player.GetAll()) do
        if player:GetName() == TimeFood.name then
            if TimeFood.time then
                Timer.ClearTimeout(TimeFood.time)
            end
        end
    end
end