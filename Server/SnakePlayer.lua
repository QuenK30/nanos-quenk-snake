--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

function SnakeClass:Constructor(player, pos, rot)
    if not player or not player:IsValid() then return end
    self.Super:Constructor(pos or Vector(), rot or Rotator(), "nanos-quenk-snake-asset::SM_SnakeHead")
    self:SetRotation(Rotator(0, SNAKE_INITIAL_YAW, 0))
    self.speed = SNAKE_SPEED
    self.body_parts = {}
    self.player = player
    player:SetValue("controlsnake", self, true)
end

function SnakeClass:SetSpeed(speed)
    self.speed = speed
end

function SnakeClass:GetSpeed()
    return self.speed
end

function SnakeClass:GetPlayer()
    return self.player
end

function SnakeClass:AddBodyPart()
    local part = StaticMesh(Vector(), Rotator(), "nanos-quenk-snake-asset::SM_SnakeTail")
    part:SetValue("pQueue", self:GetPlayer(), true)
    part:SetScale(Vector(SNAKE_BODY_SCALE))

    if #self.body_parts >= 1 then
        part:SetRotation(self.body_parts[#self.body_parts]:GetRotation())
        part:SetLocation(self.body_parts[#self.body_parts]:GetLocation())
    else
        part:SetRotation(self:GetRotation())
        part:SetLocation(self:GetLocation())
    end

    self.body_parts[#self.body_parts + 1] = part
    self:UpdateBody()
end

function SnakeClass:UpdateBody(delta)
    local body = self:GetBody()
    local moveTime = self:GetSpeed() / 100
    delta = delta or 0.0001

    for i, part in ipairs(body) do
        local prevPart = body[i - 1] or self
        part:SetLocation(NanosMath.VInterpTo(part:GetLocation(), prevPart:GetLocation(), delta, moveTime))
        part:SetRotation(NanosMath.RInterpTo(part:GetRotation(), prevPart:GetRotation(), delta, moveTime))
    end
end

function SnakeClass:GetBody()
    return self.body_parts
end

Server.Subscribe("Tick", function(delta)
    for _, snake in ipairs(SnakeClass.GetAll()) do
        local speed = snake:GetSpeed()

        if snake._direction then
            if snake._direction == PLAYER_DIR_LEFT then
                snake:SetRotation(NanosMath.RInterpTo(
                    snake:GetRotation(),
                    snake:GetRotation() + Rotator(0, (delta * speed) * -0.5, 0),
                    delta,
                    10
                ))
            elseif snake._direction == PLAYER_DIR_RIGHT then
                snake:SetRotation(NanosMath.RInterpTo(
                    snake:GetRotation(),
                    snake:GetRotation() + Rotator(0, (delta * speed) * 0.5, 0),
                    delta,
                    10
                ))
            end
        end

        local forward = snake:GetRotation():GetRightVector() * (delta * speed)
        snake:SetLocation(snake:GetLocation() + forward)
        snake:UpdateBody(delta)
    end
end)
