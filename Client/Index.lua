--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--
Package.Require("SnakeCEvents.lua")

-- Palette "Retrowave Sunset Arcade"
local C_CYAN     = Color(0.25, 0.90, 1.00, 1)
local C_MAGENTA  = Color(1.00, 0.15, 0.60, 1)
local C_GOLD     = Color(1.00, 0.84, 0.20, 1)
local C_SILVER   = Color(0.78, 0.80, 0.88, 1)
local C_BRONZE   = Color(0.80, 0.52, 0.28, 1)
local C_RED      = Color(1.00, 0.25, 0.30, 1)
local C_RED_GLOW = Color(1.00, 0.25, 0.30, 0.25)
local C_TEXT     = Color(0.93, 0.93, 0.98, 1)
local C_TEXT_DIM = Color(0.55, 0.55, 0.68, 0.85)
local C_PANEL_BG = Color(0.05, 0.03, 0.11, 0.80)

local RANK_COLORS = { C_GOLD, C_SILVER, C_BRONZE, C_TEXT_DIM, C_TEXT_DIM }

local EAT_FLASH_DURATION = 24 -- ~0.4s à 60fps

local function fmtScore(n)
    return string.format("%05d", n)
end

-- Interpolation cyan -> magenta sur composants connus (pas de lecture de propriété Color)
local function shimmerColor(t, alpha)
    return Color(0.25 + t * 0.75, 0.90 - t * 0.75, 1.00 - t * 0.40, alpha)
end

local function drawGlowPanel(canvas, px, py, pw, ph, accent, glow)
    canvas:DrawBox(Vector2D(px - 5, py - 5), Vector2D(pw + 10, ph + 10), 5, glow)
    canvas:DrawRect("", Vector2D(px, py), Vector2D(pw, ph), C_PANEL_BG, BlendMode.Translucent)
    canvas:DrawBox(Vector2D(px, py), Vector2D(pw, ph), 2, accent)
end

local function drawCornerBrackets(canvas, px, py, pw, ph, color)
    local L, t, o = 14, 2, 3
    local x1, y1 = px - o, py - o
    local x2, y2 = px + pw + o, py + ph + o
    canvas:DrawLine(Vector2D(x1, y1), Vector2D(x1 + L, y1), t, color)
    canvas:DrawLine(Vector2D(x1, y1), Vector2D(x1, y1 + L), t, color)
    canvas:DrawLine(Vector2D(x2, y1), Vector2D(x2 - L, y1), t, color)
    canvas:DrawLine(Vector2D(x2, y1), Vector2D(x2, y1 + L), t, color)
    canvas:DrawLine(Vector2D(x1, y2), Vector2D(x1 + L, y2), t, color)
    canvas:DrawLine(Vector2D(x1, y2), Vector2D(x1, y2 - L), t, color)
    canvas:DrawLine(Vector2D(x2, y2), Vector2D(x2 - L, y2), t, color)
    canvas:DrawLine(Vector2D(x2, y2), Vector2D(x2, y2 - L), t, color)
end

-- Titre avec aberration chromatique "tracking VHS" (léger tremblement animé)
local function drawGlitchTitle(canvas, text, x, y, font, size, color, kerning, blinkFrame)
    local w1x = math.sin(blinkFrame * 0.13) * 2
    local w1y = math.cos(blinkFrame * 0.09) * 1.5
    local w2x = math.sin(blinkFrame * 0.11 + 2.1) * 2
    local w2y = math.cos(blinkFrame * 0.15 + 1.3) * 1.5
    canvas:DrawText(text, Vector2D(x - 2 - w1x, y - 1 - w1y), font, size, C_CYAN, kerning, true)
    canvas:DrawText(text, Vector2D(x + 2 + w2x, y + 1 + w2y), font, size, C_MAGENTA, kerning, true)
    canvas:DrawText(text, Vector2D(x, y), font, size, color, kerning, true, false, Color.TRANSPARENT, Vector2D(0, 0), true, Color(0, 0, 0, 0.6))
end

-- Rangée de "chase lights" façon enseigne d'arcade au-dessus d'un panneau
local function drawMarqueeLights(canvas, px, py, pw, blinkFrame)
    local count = 14
    for i = 0, count - 1 do
        local x = px + (i / (count - 1)) * pw
        local brightness = 0.3 + 0.7 * (0.5 + 0.5 * math.sin(blinkFrame * 0.15 - i * 0.6))
        local col = (i % 2 == 0) and Color(1.00, 0.84, 0.20, brightness) or Color(1.00, 0.15, 0.60, brightness)
        canvas:DrawPolygon("", Vector2D(x, py - 18), Vector2D(4, 4), 12, col)
    end
end

-- Éclat radial transitoire (consommation d'un fruit) — localisé, ~0.4s
local function drawEatBurst(canvas, cx0, cy0, progress)
    local len = 4 + progress * 22
    local alpha = 1 - progress
    for i = 0, 7 do
        local ang = i * (math.pi / 4)
        local ex = cx0 + math.cos(ang) * len
        local ey = cy0 + math.sin(ang) * len
        canvas:DrawLine(Vector2D(cx0, cy0), Vector2D(ex, ey), 2, Color(1.00, 0.84, 0.20, alpha))
    end
end

local isOnStartScreen = false
local isDead = false
local deathScore = 0
local blinkFrame = 0
local eatFlashFrames = 0

local hud = Canvas(true, Color.TRANSPARENT, 0, true)

hud:Subscribe("Update", function(self, width, height)
    local player = Client.GetLocalPlayer()
    if not player then return end

    blinkFrame = blinkFrame + 1
    local pulse = 0.45 + 0.55 * (0.5 + 0.5 * math.sin(blinkFrame * 0.07))
    local pulseGold = Color(1.00, 0.84, 0.20, pulse)
    local shimmerT = 0.5 + 0.5 * math.sin(blinkFrame * 0.03)
    local shimmerAccent = shimmerColor(shimmerT, 1)
    local shimmerGlow = shimmerColor(shimmerT, 0.25)
    local cornerShimmer = shimmerColor(1 - shimmerT, 1)
    if eatFlashFrames > 0 then eatFlashFrames = eatFlashFrames - 1 end

    local cx = width / 2
    local cy = height / 2
    local bestScore = player:GetValue("BestScore", 0)
    local MONO = FontType.RobotoMono

    if isOnStartScreen then
        local pw, ph = 360, 260
        local px, py = cx - pw / 2, cy - ph / 2
        drawGlowPanel(self, px, py, pw, ph, shimmerAccent, shimmerGlow)
        drawCornerBrackets(self, px, py, pw, ph, cornerShimmer)
        drawMarqueeLights(self, px, py, pw, blinkFrame)

        drawGlitchTitle(self, T("UI_TITLE"), cx, py + 62, MONO, 34, C_GOLD, 3, blinkFrame)
        self:DrawLine(Vector2D(cx - 60, py + 96), Vector2D(cx + 60, py + 96), 2, shimmerAccent)
        self:DrawText(">───────────────●", Vector2D(cx, py + 122), MONO, 18, C_CYAN, 0, true)

        if bestScore > 0 then
            self:DrawText(T("UI_BEST", fmtScore(bestScore)), Vector2D(cx, py + 162), MONO, 16, C_GOLD, 0, true)
        end

        self:DrawText(T("UI_PRESS_ENTER"), Vector2D(cx, py + 226), MONO, 17, pulseGold, 0, true)
    elseif isDead then
        local pw, ph = 380, 280
        local px, py = cx - pw / 2, cy - ph / 2
        drawGlowPanel(self, px, py, pw, ph, C_RED, C_RED_GLOW)
        drawCornerBrackets(self, px, py, pw, ph, C_GOLD)
        drawMarqueeLights(self, px, py, pw, blinkFrame)

        drawGlitchTitle(self, T("UI_GAME_OVER"), cx, py + 50, MONO, 30, C_TEXT, 2, blinkFrame)
        self:DrawText(T("UI_SCORE", fmtScore(deathScore)), Vector2D(cx, py + 108), MONO, 16, C_TEXT, 0, true)
        self:DrawText(T("UI_BEST_DEATH", fmtScore(bestScore)), Vector2D(cx, py + 136), MONO, 16, C_TEXT_DIM, 0, true)

        if deathScore > 0 and deathScore >= bestScore then
            self:DrawText(T("UI_NEW_RECORD"), Vector2D(cx, py + 175), MONO, 15, pulseGold, 0, true)
        end

        self:DrawText(T("UI_PRESS_ENTER"), Vector2D(cx, py + 244), MONO, 17, pulseGold, 0, true)
    else
        local eating = eatFlashFrames > 0
        local scorePx, scorePy, scorePw, scorePh = 16, 16, 170, 44
        local scoreAccent = eating and C_GOLD or shimmerAccent
        local scoreGlow = eating and Color(1.00, 0.84, 0.20, 0.25) or shimmerGlow
        drawGlowPanel(self, scorePx, scorePy, scorePw, scorePh, scoreAccent, scoreGlow)
        self:DrawText(T("UI_SCORE_HUD", fmtScore(player:GetValue("Score", 0))), Vector2D(scorePx + 16, scorePy + scorePh / 2), MONO, 15, eating and C_GOLD or C_TEXT, 0, false, true)

        if eating then
            local progress = 1 - (eatFlashFrames / EAT_FLASH_DURATION)
            local popupY = scorePy + scorePh / 2 - progress * 22
            self:DrawText(T("UI_EAT_POPUP"), Vector2D(scorePx + scorePw + 14, popupY), MONO, 16, Color(1.00, 0.84, 0.20, 1 - progress), 0, false, true)
            drawEatBurst(self, scorePx + scorePw, scorePy + scorePh / 2, progress)
        end

        local leaderboard = {}
        for _, v in ipairs(Player.GetAll()) do
            table.insert(leaderboard, { name = v:GetName(), score = v:GetValue("Score", 0) })
        end
        table.sort(leaderboard, function(a, b) return a.score > b.score end)

        local lbCount = math.min(#leaderboard, 5)
        local lw, lh = 200, 40 + lbCount * 18
        local lx = width - 16 - lw
        local ly = 16

        drawGlowPanel(self, lx, ly, lw, lh, shimmerAccent, shimmerGlow)
        self:DrawText(T("UI_LB_TITLE"), Vector2D(lx + lw / 2, ly + 16), MONO, 12, C_TEXT_DIM, 0, true, true)
        self:DrawLine(Vector2D(lx + 12, ly + 30), Vector2D(lx + lw - 12, ly + 30), 1, C_TEXT_DIM)

        for k, v in ipairs(leaderboard) do
            if k > 5 then break end
            local col = RANK_COLORS[k] or C_TEXT_DIM
            local name = v.name:sub(1, 8)
            local rowY = ly + 30 + k * 18
            if k == 1 then
                self:DrawRect("", Vector2D(lx + 4, rowY - 4), Vector2D(lw - 8, 16), Color(1.00, 0.84, 0.20, 0.12), BlendMode.Translucent)
            end
            self:DrawPolygon("", Vector2D(lx + 22, rowY + 6), Vector2D(5, 5), 16, col)
            self:DrawText(name .. "  " .. fmtScore(v.score), Vector2D(lx + 36, rowY), MONO, 12, C_TEXT)
        end

        self:DrawText("* Nogitsu * YohSambre *", Vector2D(10, height - 28), MONO, 10, C_TEXT_DIM)
    end
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
    local eat_sound = Sound(Vector(), "nanos-quenk-snake-asset::eat", true, true, SoundType.SFX, 0.5, 0.5)
    eatFlashFrames = EAT_FLASH_DURATION
end)
