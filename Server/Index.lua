--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Package.Require("SnakePlayer.lua")
Package.Require("SnakeEvents.lua")
Package.Require("Food.lua")

local killPlayer  -- forward declaration (mutual recursion with spawnPlayerSnake)

local function addScore(player, head)
    player:SetValue("Score", player:GetValue("Score") + 1, true)
    head:AddBodyPart()
end

local function spawnPlayerSnake(player)
    player:SetValue("Score", 0, true)

    local head = SnakeClass(player)
    head:SetValue("IsHead", true)
    player:SetValue("Head", head)

    local headScale = head:GetScale().X
    local trigger = Trigger(Vector(), Rotator(), Vector(TRIGGER_HALF_SIZE, TRIGGER_HALF_SIZE, TRIGGER_HALF_SIZE), TriggerType.Box, true, Color.GREEN, { "All" })
    trigger:AttachTo(head, AttachmentRule.KeepRelative)
    trigger:SetRelativeLocation(head:GetRotation():GetForwardVector() * headScale * TRIGGER_HALF_SIZE)
    head:SetValue("Trigger", trigger)

    trigger:Subscribe("BeginOverlap", function(_, other)
        if not other:IsValid() then return end
        if other:GetValue("IsFood") then
            other:Destroy()
            addScore(player, head)
        elseif other:GetValue("pQueue") ~= player then
            local ownerPlayer = other:GetValue("pQueue")
            if ownerPlayer == nil then return end
            Chat.BroadcastMessage("Le joueur <blue>" .. player:GetName() .. "</> a mangé <blue>" .. ownerPlayer:GetName() .. "</> !")
            killPlayer(player)
        else
            Chat.BroadcastMessage("<blue>" .. player:GetName() .. "</> s'est mordu la queue !")
            killPlayer(player)
        end
    end)
end

killPlayer = function(player)
    local head = player:GetValue("Head")
    if not head then return end

    local bodyParts = head:GetBody()
    for _, part in ipairs(bodyParts) do
        part:SetCollision(CollisionType.NoCollision)
        part:SetValue("IsFood", true)
        part:SetLifeSpan(BODY_LIFESPAN)
    end

    local trigger = head:GetValue("Trigger")
    if trigger then trigger:Destroy() end

    head:Destroy()
    -- Ne pas respawn immédiatement — attendre que le client confirme via Snake:Respawn
    Events.CallRemote("Snake:Died", player)
end

Events.SubscribeRemote("Snake:Respawn", function(player)
    spawnPlayerSnake(player)
end)

Player.Subscribe("Spawn", function(player)
    spawnPlayerSnake(player)
    Chat.BroadcastMessage("Le joueur <blue>" .. player:GetName() .. "</> a rejoint la partie !")
end)

Server.Subscribe("Start", function()
    math.randomseed(os.time())
end)

Player.Subscribe("Destroy", function(player)
    local char = player:GetControlledCharacter()
    if char then char:Destroy() end
end)
