local PLAYER = FindMetaTable('Player')

function PLAYER:GetJumpLevel()
    return self:GetNWInt('jump_level')
end

function PLAYER:SetJumpLevel(level)
    self:SetNWInt('jump_level', level)
end

function PLAYER:GetMaxJumpLevel(level)
    return self:GetNWInt('max_jump_level')
end

function PLAYER:SetMaxJumpLevel(level)
    self:SetNWInt('max_jump_level', level)
end

function PLAYER:GetExtraJumpPower()
    return self:GetNWFloat('extra_jump_power')
end

function PLAYER:SetExtraJumpPower(power)
    self:SetNWFloat('extra_jump_power', power)
end