--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Package.Require("SnakePlayer.lua")
Package.Require("SnakeEvents.lua")
Package.Require("Food.lua")
-- Spawn player snake
Player.Subscribe("Spawn", function(player)
    randomSpawnFood(player)
    player:SetValue("Score", 0, true)
    player:SetValue("PlayerName", player:GetName(), true)

    local head = SnakeClass(player)
    head:SetValue("IsHead", true)
    player:SetValue("Head", head)
    local head_scale = head:GetScale().X

    -- Set trigger to detect collision with food
    local trigger = Trigger(Vector(), Rotator(), Vector(50, 50, 50), TriggerType.Box, true, Color.GREEN)
    trigger:AttachTo(head, AttachmentRule.KeepRelative)
    trigger:SetRelativeLocation(head:GetRotation():GetForwardVector() * head_scale * 50)
    head:SetValue("Trigger", trigger)

    trigger:Subscribe("BeginOverlap", function(self, other)
        if not other:IsValid() then return end
        if other:GetValue("IsFood") then
            other:Destroy()
            AddScore(player, head)
            randomSpawnFood(player)
        elseif other:GetValue("pQueue") ~= player then
            local player_name = other:GetValue("pQueue")
            if player_name == nil then return end
            Chat.BroadcastMessage("Le joueur <blue>" .. player:GetName() .. "</> a mangé <blue>" .. player_name .. "</> !")
            KillPlayer(player)
        else
            Chat.BroadcastMessage("Tu as touché: <blue>" .. other:GetName() .. "</> !")
        end
    end)

    if player:GetName() == "Nogitsu" then
        Chat.BroadcastMessage("Le joueur <blue>" .. player:GetName() .. "</>  bien moche sa mère a rejoint la partie !")
    else
        Chat.BroadcastMessage("Le joueur <blue>" .. player:GetName() .. "</> a rejoint la partie !")
    end


end)

--kill the player and put his body part on the ground
function KillPlayer(player)
    local head = player:GetValue("Head")
    if head then
        local body_parts = player:GetValue("pQueue")
        if body_parts then
            for _, body_part in pairs(body_parts) do
                body_part:SetCollision(CollisionType.NoCollision)
                body_part:SetValue("IsFood", true)
                body_part:SetNetworkAuthority(NetworkAuthority.None)
                body_part:SetLifeSpan(30)
            end
        end

        if head:GetValue("Trigger") then
            head:GetValue("Trigger"):Destroy()
        end

        head:Destroy()
        stopTimerFood()
        respawnPlayer(player)
    end
end

function respawnPlayer(player)
    Events.Call("Spawn",player)
end

function AddScore(player, head)
    player:SetValue("Score", player:GetValue("Score") + 1, true)
    head:AddBodyPart()
end

function GetScore(player)
    return player:GetValue("Score")
end

-- Spawn food
Server.Subscribe("Start", function()
    Console.Log("Server started")
end)
Player.Subscribe("Destroy", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        char:Destroy()
    end
end)