--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

function Player:GetControl()
    local pSnake = self:GetValue("controlsnake")
    if pSnake and pSnake:IsValid() then
        return pSnake
    end
end