--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--
Package.Require("SnakeCEvents.lua")


-- score hud
local score = Canvas(
        true,
        Color.TRANSPARENT,
        0,
        true
)

score:Subscribe("Update", function(self,width,height)
    local player = Client.GetLocalPlayer()
    if not player then return end
    self:DrawText("Score: "..player:GetValue("Score", 0), Vector2D(40,60))


    local leaderboard = {}
    for k,v in pairs(Player.GetAll()) do
        table.insert(leaderboard, {name = v:GetName(), score = v:GetValue("Score", 0)})
    end

    table.sort(leaderboard, function(a,b) return a.score > b.score end)

    local x = width - 200
    local y = 60
    self:DrawText("Leaderboard", Vector2D(x, y), FontType.Roboto, 12, Color.RED)
    for k,v in pairs(leaderboard) do
        if k > 5 then break end
        if k == 1 then
            self:DrawText(v.name .. " : " .. v.score, Vector2D(x, y + k * 20), FontType.Roboto, 12, Color.YELLOW)
        else
        self:DrawText(v.name .. " : " .. v.score, Vector2D(x, y + k * 20), FontType.Roboto, 12, Color.WHITE)
        end
    end


    local testers = {
        "Nogitsu",
        "YohSambre"
    }
    self:DrawText("Testers:", Vector2D(10, height - 60), FontType.Roboto, 12, Color.WHITE)
    for k,v in pairs(testers) do
        self:DrawText(v, Vector2D(10, height - 60 + k * 20), FontType.Roboto, 12, Color.WHITE)
    end
end)
