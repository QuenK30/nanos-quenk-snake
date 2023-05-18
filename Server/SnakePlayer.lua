--[[
    Project: "NanosSnake"
    Date: 08.05.2023
    Description: Gamemode for NanosWorld - Snake
    Author: QuenK
]]--

function SnakeClass:Constructor(sPlayer, pos, rot)
    if not sPlayer or not sPlayer:IsValid() then return end
    self.Super:Constructor(tPos or Vector(), tRot or Rotator(), "snake::SM_SnakeHead")
    self:SetRotation(Rotator(0, 90, 0))
    self.speed = 900
    self.body_parts = {}
    self.player = sPlayer
    sPlayer:SetValue("controlsnake", self, true)
end

function SnakeClass:SetSpeed(sSpeed)
    self.speed = sSpeed
end

function SnakeClass:GetSpeed()
    return self.speed
end

function SnakeClass:GetPlayer()
    return self.player
end

function SnakeClass:AddBodyPart()
    local sPart = StaticMesh(Vector(), Rotator(), "snake::SM_SnakeTail")
    sPart:SetValue("pQueue", self:GetPlayer(), true)
    sPart:SetScale(Vector(0.7))

    if (#self.body_parts >= 1) then
        sPart:SetRotation(self.body_parts[#self.body_parts]:GetRotation())
        sPart:SetLocation(self.body_parts[#self.body_parts]:GetLocation())
    else
        sPart:SetRotation(self:GetRotation())
        sPart:SetLocation(self:GetLocation())
    end

    self.body_parts[#self.body_parts + 1] = sPart

    self:UpdateBody()
end

function SnakeClass:RemoveLastBodyPart()
    local sTails = #self.body_parts
    if (sTails <= 0) then return end

    self.body_parts[sTails]:Destroy()
    self.body_parts[sTails] = nil

    self:UpdateBody()
end

function SnakeClass:UpdateBody(fDelta)
    local tBody = self:GetBody()
    local iSpeed = self:GetSpeed()
    local fMoveTime = (iSpeed / 100)

    fDelta = (fDelta or 0.0001)

    for iID, ePart in ipairs(tBody) do
        local ePrevPart = tBody[iID - 1] and tBody[iID - 1] or self

        ePart:SetLocation(NanosMath.VInterpTo(ePart:GetLocation(), ePrevPart:GetLocation(), fDelta, fMoveTime))
        ePart:SetRotation(NanosMath.RInterpTo(ePart:GetRotation(), ePrevPart:GetRotation(), fDelta, fMoveTime))
    end
end


function SnakeClass:GetBody()
    return self.body_parts
end

Server.Subscribe("Tick", function(fDelta)
    for _, v in ipairs(SnakeClass.GetAll()) do
        local iSpeed = v:GetSpeed()

        if v._direction then
            if v._direction == PLAYER_DIR_LEFT then
                v:SetRotation(NanosMath.RInterpTo(
                    v:GetRotation(),
                    v:GetRotation() + Rotator(0, (fDelta * iSpeed) * -0.5, 0),
                    fDelta,
                    10
                ))
            elseif v._direction == PLAYER_DIR_RIGHT then
                v:SetRotation(NanosMath.RInterpTo(
                    v:GetRotation(),
                    v:GetRotation() + Rotator(0, (fDelta * iSpeed) * 0.5, 0),
                    fDelta,
                    10
                ))
            end
        end

        local tForward = v:GetRotation():GetRightVector() * (fDelta * iSpeed)
        v:SetLocation(v:GetLocation() + tForward)

        v:UpdateBody(fDelta)
    end
end)
