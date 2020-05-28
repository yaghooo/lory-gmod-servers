ITEM.Name = "Text Hat"
ITEM.Price = 10000
ITEM.Model = "models/extras/info_speech.mdl"
ITEM.NoPreview = true
local MaxTextLength = 32

function ITEM:OnEquip()
end

ITEM.OnHolster = ITEM.OnEquip

function ITEM:Modify(modifications)
    if not modifications then
        modifications = {}
    end

    Derma_StringRequest("Texto", "Qual texto você quer que seu chapeu fale?", "", function(text)
        modifications.text = string.sub(text, 1, MaxTextLength)
        PS:ShowColorChooser(self, modifications)
    end)
end

hook.Add("PostPlayerDraw", "DrawTextHat", function(ply)
    local itemId = "texthat"

    if ply:PS_HasItemEquipped(itemId) and ply:Alive() then
        local modifications = ply.PS_Items[itemId].Modifiers
        if modifications and modifications.text then
            local offset = Vector(0, 0, 79)
            local ang = LocalPlayer():EyeAngles()
            local pos = ply:GetPos() + offset + ang:Up()
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.1)
            draw.DrawText(modifications.text, THEME.Font.Coolvetica30, 2, 2, modifications.color or color_white, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    end
end)