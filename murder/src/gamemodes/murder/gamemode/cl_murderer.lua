function GM:SetMurderer(murderer)
    self.Murderer = murderer
end

function GM:IsMurderer()
    return self.Murderer
end

function GM:SetKnife(knife)
    self.CurrentMurderKnife = knife
end

function GM:GetKnife()
    return self.CurrentMurderKnife
end

net.Receive("SetMurdererStatus", function()
    GAMEMODE:SetMurderer(net.ReadBool())
end)

net.Receive("SetKnife", function()
    GAMEMODE:SetKnife(net.ReadString())
end)