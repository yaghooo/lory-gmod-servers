local PANEL = {}

function PANEL:Init()
    self.StartTime = CurTime()
end

function PANEL:SetData(data)
    self.Data = data
    self:SetTitle("Enviar " .. data.Name)
    self:SetSize(300, 130)
    self:SetDeleteOnClose(true)
    self:SetBackgroundBlur(true)
    self:SetDrawOnTop(true)
    local DLabel = vgui.Create("DLabel", self)
    DLabel:SetText("Jogador:")
    DLabel:Dock(TOP)
    DLabel:DockMargin(4, 0, 4, 4)
    DLabel:SizeToContents()
    self.DComboBox = vgui.Create("DComboBox", self)
    self.DComboBox:SetValue("Selecionar jogador")
    self.DComboBox:SetTall(24)
    self.DComboBox:Dock(TOP)

    self.DComboBox.OnSelect = function(s, i, name, value)
        if value then
            self.SelectedUserUniqueId = value
            self.DButtonDone:SetDisabled(false)
        else
            self.DButtonDone:SetDisabled(true)
        end
    end

    self:FillPlayers()
    local DPanelButtonList = vgui.Create("DPanel", self)
    DPanelButtonList:SetPaintBackground(false)
    DPanelButtonList:DockMargin(0, 5, 0, 0)
    DPanelButtonList:Dock(BOTTOM)
    local DButtonCancel = vgui.Create("DButton", DPanelButtonList)
    DButtonCancel:SetText("")
    DButtonCancel:DockMargin(4, 0, 0, 0)
    DButtonCancel:SetColor(Color(219, 105, 105))
    DButtonCancel:Dock(RIGHT)

    DButtonCancel.DoClick = function()
        self:Close()
    end

    function DButtonCancel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(219, 105, 105))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(232, 90, 90))
        draw.SimpleText("CANCELAR", "PS_CatName", w / 2, h / 2, ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.DButtonDone = vgui.Create("DButton", DPanelButtonList)
    self.DButtonDone:SetText("")
    self.DButtonDone:SetDisabled(true)
    self.DButtonDone:DockMargin(0, 0, 4, 0)
    self.DButtonDone:Dock(RIGHT)

    self.DButtonDone.DoClick = function()
        self:Submit()
        self:Close()
    end

    function self.DButtonDone:Paint(w, h)
        local opc = self:GetDisabled() and 50 or 150
        draw.RoundedBox(0, 0, 0, w, h, Color(123, 227, 149, opc))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
        draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(123, 227, 149, opc))
        draw.SimpleText("Enviar", "PS_CatName", w / 2, h / 2, ColorAlpha(color_white, opc), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.btnClose.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h - 10, Color(219, 105, 105))
        draw.RoundedBox(0, 1, 1, w - 2, h - 12, Color(232, 90, 90))
        draw.SimpleText("X", "PS_CatName", w / 2, h / 2 - 5, ColorAlpha(color_white, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.btnMaxim.Paint = function() end
    self.btnMinim.Paint = function() end
    self:Center()
    self:MakePopup()
end

function PANEL:FillPlayers()
    for _, ply in pairs(player.GetAll()) do
        if ply ~= LocalPlayer() then
            self.DComboBox:AddChoice(ply:Nick(), ply:UniqueID())
        end
    end
end

function PANEL:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.StartTime)
    draw.RoundedBox(0, 0, 0, w, h, Color(57, 61, 72))
    draw.RoundedBox(0, 1, 1, w - 2, h - 2, ColorAlpha(color_white, 10))
    draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(57, 61, 72))
end

function PANEL:Submit()
    local other = false

    for _, ply in pairs(player.GetAll()) do
        if tonumber(ply:UniqueID()) == tonumber(self.SelectedUserUniqueId) then
            other = ply
            break
        end
    end

    if not other then return end -- player could have left
    net.Start("PS_SendItem")
    net.WriteEntity(other)
    net.WriteString(self.Data.ID)
    net.SendToServer()
end

vgui.Register("DPointShopGiveItem", PANEL, "DFrame")