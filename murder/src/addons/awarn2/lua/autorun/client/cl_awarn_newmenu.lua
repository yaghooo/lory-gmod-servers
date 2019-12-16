--AddCSLuaFile()
AWarn.NewMenu = AWarn.NewMenu or {}

surface.CreateFont("MenuFont1", {
    font = "Arial",
    size = 18,
    weight = 800,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = true,
    additive = false,
    outline = false
})

function AWarn.NewMenu:ShowNewMenu(ply, com, args)
    self.new_menu = vgui.Create("new_menu")
    self.new_menu:MakePopup()
end

--concommand.Add( "awarn_newmenu", function( ... ) AWarn.NewMenu:ShowNewMenu( ... ) end )
local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() - 100, ScrH() - 100)
    self:Center()
    self:DrawFrame()
    self:SetTitle("")
    self:SetDraggable(false)
end

function PANEL:Paint()
    local plist_x = self:GetWide() - 192 + 8
    --Main Window--	
    surface.SetDrawColor(0, 0, 0, 210)
    surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
    surface.DrawRect(plist_x, 29, 180, self:GetTall() - 33) --PlayerListPanel
    surface.DrawRect(4, 4, self:GetWide() - 8, 22) --TopPanel
    surface.DrawRect(4, 29, self:GetWide() - 192, self:GetTall() - 33) --WarningsBodyPanel
    --Player Name Text--
    surface.SetFont("MenuFont1")
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(plist_x, 128)
    surface.DrawText("Hello World")
end

function PANEL:DrawFrame()
end

vgui.Register("new_menu", PANEL, "DFrame")