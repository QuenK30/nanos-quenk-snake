--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Events.SubscribeRemote("Snake:KeyPress", function(pPlayer, iDir)
    local eSnake = pPlayer:GetControl()
    if not eSnake then return end

    eSnake._direction = iDir
end)

Events.SubscribeRemote("Snake:KeyRelease", function(pPlayer, iDir)
    local eSnake = pPlayer:GetControl()
    if not eSnake then return end

    if eSnake._direction and eSnake._direction == iDir then
        eSnake._direction = nil
    end
end)