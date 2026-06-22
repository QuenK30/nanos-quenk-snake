--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

local function spawnFood()
    local x = math.random(-MAP_SIZE / 2, MAP_SIZE / 2)
    local y = math.random(-MAP_SIZE / 2, MAP_SIZE / 2)
    local food = StaticMesh(Vector(x, y, 0), Rotator(), "nanos-quenk-snake-asset::SM_Mushroom")
    food:SetValue("IsFood", true)
end

local function foodLoop()
    spawnFood()
    Timer.SetTimeout(foodLoop, math.random(FOOD_SPAWN_MIN_SEC, FOOD_SPAWN_MAX_SEC) * 1000)
end

Server.Subscribe("Start", function()
    foodLoop()
end)
