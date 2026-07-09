--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Input.Bind("MoveLeft", InputEvent.Pressed, function() Events.CallRemote("Snake:KeyPress", Reliability.Reliable, PLAYER_DIR_LEFT) end)
Input.Bind("MoveLeft", InputEvent.Released, function() Events.CallRemote("Snake:KeyRelease", Reliability.Reliable, PLAYER_DIR_LEFT) end)

Input.Bind("MoveRight", InputEvent.Pressed, function() Events.CallRemote("Snake:KeyPress", Reliability.Reliable, PLAYER_DIR_RIGHT) end)
Input.Bind("MoveRight", InputEvent.Released, function() Events.CallRemote("Snake:KeyRelease", Reliability.Reliable, PLAYER_DIR_RIGHT) end)

if DEBUG_MODE then
    Input.Register("Debug Add Score", "U")
    Input.Bind("Debug Add Score", InputEvent.Pressed, function() Events.CallRemote("Snake:DebugAddScore", Reliability.Reliable) end)
end

-- Pre-calculated once — avoids allocating new Vector/Rotator every Tick frame
local CAM_OFFSET = Vector(CAM_FORWARD_OFFSET, 0, CAM_HEIGHT)
local CAM_ROT = Rotator(CAM_PITCH, 0, 0)

Client.Subscribe("Tick", function()
    local player = Client.GetLocalPlayer()
    if not player then return end

    local snake = player:GetControl()
    if not snake then return end

    player:SetCameraLocation(snake:GetLocation() + CAM_OFFSET)
    player:SetCameraRotation(CAM_ROT)
end)