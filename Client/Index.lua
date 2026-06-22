--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--
Package.Require("SnakeCEvents.lua")

local isDead = false
local deathScore = 0

local hud = Canvas(true, Color.TRANSPARENT, 0, true)

hud:Subscribe("Update", function(self, width, height)
    local player = Client.GetLocalPlayer()
    if not player then return end

    -- Écran de mort
    if isDead then
        local cx = width / 2
        local cy = height / 2

        self:DrawText("Vous etes mort !", Vector2D(cx - 120, cy - 90), FontType.Roboto, 28, Color.RED)
        self:DrawText("Score de la session : " .. deathScore, Vector2D(cx - 130, cy - 40), FontType.Roboto, 20, Color.WHITE)
        self:DrawText("[ REJOUER ]", Vector2D(cx - 70, cy + 20), FontType.Roboto, 22, Color.GREEN)
        self:DrawText("Appuyez sur ENTREE", Vector2D(cx - 100, cy + 60), FontType.Roboto, 13, Color.WHITE)
        return
    end

    -- HUD normal
    self:DrawText("Score: " .. player:GetValue("Score", 0), Vector2D(40, 60))

    local leaderboard = {}
    for _, v in ipairs(Player.GetAll()) do
        table.insert(leaderboard, { name = v:GetName(), score = v:GetValue("Score", 0) })
    end

    table.sort(leaderboard, function(a, b) return a.score > b.score end)

    local x = width - 200
    local y = 60
    self:DrawText("Leaderboard", Vector2D(x, y), FontType.Roboto, 12, Color.RED)
    for k, v in ipairs(leaderboard) do
        if k > 5 then break end
        if k == 1 then
            self:DrawText(v.name .. " : " .. v.score, Vector2D(x, y + k * 20), FontType.Roboto, 12, Color.YELLOW)
        else
            self:DrawText(v.name .. " : " .. v.score, Vector2D(x, y + k * 20), FontType.Roboto, 12, Color.WHITE)
        end
    end

    local testers = { "Nogitsu", "YohSambre" }
    self:DrawText("Testers:", Vector2D(10, height - 60), FontType.Roboto, 12, Color.WHITE)
    for k, v in ipairs(testers) do
        self:DrawText(v, Vector2D(10, height - 60 + k * 20), FontType.Roboto, 12, Color.WHITE)
    end
end)

Events.SubscribeRemote("Snake:Died", function()
    isDead = true
    deathScore = Client.GetLocalPlayer():GetValue("Score", 0)
end)

Input.Register("Rejouer", "Enter")
Input.Bind("Rejouer", InputEvent.Pressed, function()
    if not isDead then return end
    isDead = false
    Events.CallRemote("Snake:Respawn")
end)
