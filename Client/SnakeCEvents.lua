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

Client.Subscribe("Tick", function()
    local pPlayer = Client.GetLocalPlayer()
    if not pPlayer then return end

    local eSnake = pPlayer:GetControl()
    if not eSnake then return end

    local tSnakeLoc = eSnake:GetLocation()
    local tCamLoc = tSnakeLoc + Vector(0, 0, 4000)
    pPlayer:SetCameraLocation(tCamLoc + Vector(-900, 0, 0))
    pPlayer:SetCameraRotation(Rotator(-90, 0, 0))
end)