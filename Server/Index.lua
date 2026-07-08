--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

Package.Require("Database.lua")
Package.Require("SnakePlayer.lua")
Package.Require("SnakeEvents.lua")
Package.Require("Food.lua")

local killPlayer  -- forward declaration (mutual recursion with spawnPlayerSnake)

local function addScore(player, head)
    player:SetValue("Score", player:GetValue("Score") + 1, true)
    head:AddBodyPart()
    Events.CallRemote("Snake:Eat", player)
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
            Chat.BroadcastMessage(T("CHAT_PLAYER_ATE", player:GetName(), ownerPlayer:GetName()))
            killPlayer(player)
        else
            Chat.BroadcastMessage(T("CHAT_SELF_BITE", player:GetName()))
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

    -- Mise à jour du best score avant d'envoyer l'événement au client
    local score = player:GetValue("Score", 0)
    local accountId = player:GetAccountID()
    UpdatePlayerBestScore(accountId, score)
    player:SetValue("BestScore", GetPlayerBestScore(accountId), true)

    Events.CallRemote("Snake:Died", player)
end

Events.SubscribeRemote("Snake:StartGame", function(player)
    spawnPlayerSnake(player)
end)

Events.SubscribeRemote("Snake:Respawn", function(player)
    spawnPlayerSnake(player)
end)

Events.SubscribeRemote("Snake:DebugAddScore", function(player)
    if not DEBUG_MODE then return end
    local head = player:GetValue("Head")
    if not head or not head:IsValid() then return end
    addScore(player, head)
end)

Player.Subscribe("Spawn", function(player)
    local accountId = player:GetAccountID()
    local bestScore = GetPlayerBestScore(accountId)
    player:SetValue("BestScore", bestScore, true)
    Chat.BroadcastMessage(T("CHAT_PLAYER_JOINED", player:GetName()))
    -- Ne pas spawner le serpent ici — attendre que le client envoie Snake:StartGame
    Events.CallRemote("Snake:Ready", player)
end)

Server.Subscribe("Start", function()
    math.randomseed(os.time())
end)

Player.Subscribe("Destroy", function(player)
    -- Sauvegarder le score si le joueur se déconnecte en pleine partie
    local score = player:GetValue("Score", 0)
    if score > 0 then
        UpdatePlayerBestScore(player:GetAccountID(), score)
    end
    -- Nettoyer le serpent actif
    local head = player:GetValue("Head")
    if head and head:IsValid() then
        local trigger = head:GetValue("Trigger")
        if trigger then trigger:Destroy() end
        for _, part in ipairs(head:GetBody()) do
            part:Destroy()
        end
        head:Destroy()
    end
    local char = player:GetControlledCharacter()
    if char then char:Destroy() end
end)
