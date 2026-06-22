--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Input.Register("Turn Left", "Q")
Input.Bind("Turn Left", InputEvent.Pressed, function() Events.CallRemote("Snake:KeyPress", PLAYER_DIR_LEFT) end)
Input.Bind("Turn Left", InputEvent.Released, function() Events.CallRemote("Snake:KeyRelease", PLAYER_DIR_LEFT) end)

Input.Register("Turn Right", "D")
Input.Bind("Turn Right", InputEvent.Pressed, function() Events.CallRemote("Snake:KeyPress", PLAYER_DIR_RIGHT) end)
Input.Bind("Turn Right", InputEvent.Released, function() Events.CallRemote("Snake:KeyRelease", PLAYER_DIR_RIGHT) end)

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