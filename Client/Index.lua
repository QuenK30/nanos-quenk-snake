--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--
Package.Require("SnakeCEvents.lua")

-- Palette 90s/2000s neon web
local C_PINK   = Color(1.00, 0.20, 0.80, 1)   -- hot pink
local C_CYAN   = Color(0.00, 0.90, 1.00, 1)   -- electric cyan
local C_YELLOW = Color(1.00, 0.95, 0.00, 1)   -- neon yellow
local C_ORANGE = Color(1.00, 0.45, 0.00, 1)   -- orange flash
local C_LIME   = Color(0.20, 1.00, 0.10, 1)   -- lime green
local C_PURPLE = Color(0.60, 0.10, 0.90, 1)   -- electric purple
local C_RED    = Color(1.00, 0.12, 0.15, 1)   -- alert red

-- Couleurs par rang du leaderboard
local RANK_COLORS = { C_YELLOW, C_CYAN, C_LIME, C_ORANGE, C_PINK }

local function fmtScore(n)
    return string.format("%05d", n)
end

local isOnStartScreen = false
local isDead = false
local deathScore = 0

local hud = Canvas(true, Color.TRANSPARENT, 0, true)

hud:Subscribe("Update", function(self, width, height)
    local player = Client.GetLocalPlayer()
    if not player then return end

    local cx = width / 2
    local cy = height / 2
    local bestScore = player:GetValue("BestScore", 0)
    local MONO = FontType.RobotoMono

    -- ── Écran d'accueil ───────────────────────────────────────────────────────
    if isOnStartScreen then
        -- Ligne déco haut
        self:DrawText("✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦", Vector2D(cx - 148, cy - 122), MONO, 13, C_PURPLE)
        -- Titre avec ombre WordArt (shadow d'abord, texte par-dessus)
        self:DrawText("★   SNAKE   ★", Vector2D(cx - 110 + 3, cy - 98 + 3), MONO, 28, C_PURPLE)
        self:DrawText("★   SNAKE   ★", Vector2D(cx - 110,     cy - 98    ), MONO, 28, C_YELLOW)
        -- Serpent ASCII
        self:DrawText(">───────────────●", Vector2D(cx - 118, cy - 55), MONO, 18, C_LIME)
        -- Best score (masqué si 0)
        if bestScore > 0 then
            self:DrawText("BEST >>  " .. fmtScore(bestScore), Vector2D(cx - 95, cy - 6), MONO, 16, C_CYAN)
        end
        -- Ligne déco bas
        self:DrawText("✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦", Vector2D(cx - 148, cy + 26), MONO, 13, C_PINK)
        -- Prompt
        self:DrawText(">>> PRESS ENTER <<<", Vector2D(cx - 128, cy + 53), MONO, 17, C_ORANGE)
        return
    end

    -- ── Écran de mort ─────────────────────────────────────────────────────────
    if isDead then
        -- GAME OVER avec ombre rouge/orange
        self:DrawText("*~*  GAME OVER  *~*", Vector2D(cx - 148 + 3, cy - 96 + 3), MONO, 24, C_ORANGE)
        self:DrawText("*~*  GAME OVER  *~*", Vector2D(cx - 148,     cy - 96    ), MONO, 24, C_RED)
        -- Scores
        self:DrawText("SCORE  >>  " .. fmtScore(deathScore), Vector2D(cx - 118, cy - 43), MONO, 16, C_CYAN)
        self:DrawText("BEST   >>  " .. fmtScore(bestScore),  Vector2D(cx - 118, cy - 17), MONO, 16, C_YELLOW)
        -- Nouveau record
        if deathScore > 0 and deathScore >= bestScore then
            self:DrawText("!! NEW RECORD !!", Vector2D(cx - 108 + 2, cy + 19 + 2), MONO, 15, C_PURPLE)
            self:DrawText("!! NEW RECORD !!", Vector2D(cx - 108,     cy + 19    ), MONO, 15, C_PINK)
        end
        -- Ligne déco
        self:DrawText("✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦  ✦", Vector2D(cx - 148, cy + 49), MONO, 13, C_PURPLE)
        -- Prompt
        self:DrawText(">>> PRESS ENTER <<<", Vector2D(cx - 128, cy + 76), MONO, 17, C_ORANGE)
        return
    end

    -- ── HUD en jeu ────────────────────────────────────────────────────────────
    self:DrawText("SCORE >> " .. fmtScore(player:GetValue("Score", 0)), Vector2D(30, 28), MONO, 14, C_CYAN)

    local leaderboard = {}
    for _, v in ipairs(Player.GetAll()) do
        table.insert(leaderboard, { name = v:GetName(), score = v:GetValue("Score", 0) })
    end
    table.sort(leaderboard, function(a, b) return a.score > b.score end)

    local lx = width - 215
    local ly = 22
    self:DrawText("[ SNAKE  v1.0 ]",  Vector2D(lx, ly),      MONO, 12, C_PURPLE)
    self:DrawText("────────────────", Vector2D(lx, ly + 17),  MONO, 11, C_PINK)
    for k, v in ipairs(leaderboard) do
        if k > 5 then break end
        local col  = RANK_COLORS[k] or C_CYAN
        local name = v.name:sub(1, 8)
        self:DrawText(name .. "  " .. fmtScore(v.score), Vector2D(lx, ly + 17 + k * 17), MONO, 12, col)
    end

    self:DrawText("* Nogitsu * YohSambre *", Vector2D(10, height - 28), MONO, 10, C_PURPLE)
end)

Events.SubscribeRemote("Snake:Ready", function()
    isOnStartScreen = true
end)

Events.SubscribeRemote("Snake:Died", function()
    isDead = true
    deathScore = Client.GetLocalPlayer():GetValue("Score", 0)
end)

Input.Register("Rejouer", "Enter")
Input.Bind("Rejouer", InputEvent.Pressed, function()
    if isOnStartScreen then
        isOnStartScreen = false
        Events.CallRemote("Snake:StartGame")
    elseif isDead then
        isDead = false
        Events.CallRemote("Snake:Respawn")
    end
end)

Events.SubscribeRemote("Snake:Eat", function()
    local eat_sound = Sound(Vector(), "nanos-quenk-snake-asset::eat", true, true, SoundType.SFX, 1, 1)
end)