--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

local db = Database(DatabaseEngine.SQLite, "db=snake_stats.db")

db:Execute([[
    CREATE TABLE IF NOT EXISTS player_stats (
        account_id TEXT PRIMARY KEY,
        best_score INTEGER DEFAULT 0
    )
]])

function GetPlayerBestScore(accountId)
    local rows, err = db:Select(
        "SELECT best_score FROM player_stats WHERE account_id = :1",
        accountId
    )
    if err then
        Console.Log("[Snake] DB Select error: " .. err)
        return 0
    end
    if rows and rows[1] then
        return rows[1].best_score
    end
    return 0
end

function UpdatePlayerBestScore(accountId, score)
    local _, err = db:Execute([[
        INSERT INTO player_stats (account_id, best_score) VALUES (:1, :2)
        ON CONFLICT(account_id) DO UPDATE SET best_score = MAX(best_score, :2)
    ]], accountId, score)
    if err then
        Console.Log("[Snake] DB Execute error: " .. err)
    end
end