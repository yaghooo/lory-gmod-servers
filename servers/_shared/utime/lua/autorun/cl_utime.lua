module("Utime", package.seeall)
if not CLIENT then return end
local gpanel
local utime_enable = CreateClientConVar("utime_enable", "1.0", true, false)
local PANEL = {}
PANEL.Small = 40
PANEL.TargetSize = PANEL.Small
PANEL.Large = 100
PANEL.Wide = 160

local function initialize()
    gpanel = vgui.Create("UTimeMain")
    gpanel:SetSize(gpanel.Wide, gpanel.Small)
    hook.Remove("OnEntityCreated", "UtimeInitialize")
end

hook.Add("InitPostEntity", "UtimeInitialize", initialize)

local function think()
    local client = LocalPlayer()
    if not client:IsValid() or gpanel == nil then return end

    if not utime_enable:GetBool() or not IsValid(client) or (IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "gmod_camera") then
        gpanel:SetVisible(false)
    else
        gpanel:SetVisible(true)
    end

    gpanel:SetPos(ScrW() - gpanel:GetWide() - 30, 30)
    gpanel.lblTotalTime:SetTextColor(color_white)
    gpanel.lblSessionTime:SetTextColor(color_white)
    gpanel.total:SetTextColor(color_white)
    gpanel.session:SetTextColor(color_white)
    gpanel.playerInfo.lblTotalTime:SetTextColor(color_black)
    gpanel.playerInfo.lblSessionTime:SetTextColor(color_black)
    gpanel.playerInfo.lblNick:SetTextColor(color_black)
    gpanel.playerInfo.total:SetTextColor(color_black)
    gpanel.playerInfo.session:SetTextColor(color_black)
    gpanel.playerInfo.nick:SetTextColor(color_black)
end

timer.Create("UTimeThink", 0.6, 0, think)

-----------------------------------------------------------
--	 Name: Paint
-----------------------------------------------------------
function PANEL:Paint(w, h)
    local wide = self:GetWide()
    local tall = self:GetTall()
    local outerColor = team.GetColor(LocalPlayer():Team())
    surface.SetDrawColor(outerColor)
    surface.DrawRect(0, 0, wide, tall) -- Draw our base

    -- Draw the white background for another player's info
    if self:GetTall() > self.Small + 4 then
        surface.SetDrawColor(color_white)
        surface.DrawRect(2, self.Small, wide - 4, tall - self.Small - 2)
    end

    return true
end

-----------------------------------------------------------
--	 Name: Init
-----------------------------------------------------------
function PANEL:Init()
    self.Size = self.Small
    self.playerInfo = vgui.Create("UTimePlayerInfo", self)
    self.lblTotalTime = vgui.Create("DLabel", self)
    self.lblSessionTime = vgui.Create("DLabel", self)
    self.total = vgui.Create("DLabel", self)
    self.session = vgui.Create("DLabel", self)
end

-----------------------------------------------------------
--	 Name: ApplySchemeSettings
-----------------------------------------------------------
function PANEL:ApplySchemeSettings()
    self.lblTotalTime:SetFont("DermaDefault")
    self.lblSessionTime:SetFont("DermaDefault")
    self.total:SetFont("DermaDefault")
    self.session:SetFont("DermaDefault")
    self.lblTotalTime:SetTextColor(color_black)
    self.lblSessionTime:SetTextColor(color_black)
    self.total:SetTextColor(color_black)
    self.session:SetTextColor(color_black)
end

-----------------------------------------------------------
--	 Name: Think
-----------------------------------------------------------
local locktime = 0

function PANEL:Think()
    if self.Size == self.Small then
        self.playerInfo:SetVisible(false)
    else
        self.playerInfo:SetVisible(true)
    end

    if not IsValid(LocalPlayer()) then return end
    local tr = util.GetPlayerTrace(LocalPlayer(), LocalPlayer():GetAimVector())
    local trace = util.TraceLine(tr)
    local ply = trace.Entity

    if ply and ply:IsValid() and ply:IsPlayer() then
        self.TargetSize = self.Large
        self.playerInfo:SetPlayer(trace.Entity)
        locktime = CurTime()
    end

    if locktime + 2 < CurTime() then
        self.TargetSize = self.Small
    end

    if self.Size ~= self.TargetSize then
        self.Size = math.Approach(self.Size, self.TargetSize, (math.abs(self.Size - self.TargetSize) + 1) * 8 * FrameTime())
        self:PerformLayout()
    end

    self.total:SetText(timeToStr(LocalPlayer():GetUTimeTotalTime()))
    self.session:SetText(timeToStr(LocalPlayer():GetUTimeSessionTime()))
end

-----------------------------------------------------------
--	 Name: PerformLayout
-----------------------------------------------------------
function PANEL:PerformLayout()
    self:SetSize(self:GetWide(), self.Size)
    self.lblTotalTime:SetSize(52, 18)
    self.lblTotalTime:SetPos(8, 2)
    self.lblTotalTime:SetText("Total: ")
    self.lblSessionTime:SetSize(52, 18)
    self.lblSessionTime:SetPos(8, 20)
    self.lblSessionTime:SetText("Sessão: ")
    self.total:SetSize(self:GetWide() - 52, 18)
    self.total:SetPos(52, 2)
    self.session:SetSize(self:GetWide() - 52, 18)
    self.session:SetPos(52, 20)
    self.playerInfo:SetPos(0, 42)
    self.playerInfo:SetSize(self:GetWide() - 8, self:GetTall() - 42)
end

vgui.Register("UTimeMain", PANEL, "Panel")
local INFOPANEL = {}

-----------------------------------------------------------
--	 Name: Init
-----------------------------------------------------------
function INFOPANEL:Init()
    self.lblTotalTime = vgui.Create("DLabel", self)
    self.lblSessionTime = vgui.Create("DLabel", self)
    self.lblNick = vgui.Create("DLabel", self)
    self.total = vgui.Create("DLabel", self)
    self.session = vgui.Create("DLabel", self)
    self.nick = vgui.Create("DLabel", self)
end

-----------------------------------------------------------
--	 Name: SetPlayer
-----------------------------------------------------------
function INFOPANEL:SetPlayer(ply)
    self.Player = ply
end

-----------------------------------------------------------
--	 Name: ApplySchemeSettings
-----------------------------------------------------------
function INFOPANEL:ApplySchemeSettings()
    self.lblTotalTime:SetFont("DermaDefault")
    self.lblSessionTime:SetFont("DermaDefault")
    self.lblNick:SetFont("DermaDefault")
    self.total:SetFont("DermaDefault")
    self.session:SetFont("DermaDefault")
    self.nick:SetFont("DermaDefault")
    self.lblTotalTime:SetTextColor(color_black)
    self.lblSessionTime:SetTextColor(color_black)
    self.lblNick:SetTextColor(color_black)
    self.total:SetTextColor(color_black)
    self.session:SetTextColor(color_black)
    self.nick:SetTextColor(color_black)
end

-----------------------------------------------------------
--	 Name: Think
-----------------------------------------------------------
function INFOPANEL:Think()
    local ply = self.Player

    -- Disconnected
    if not ply or not ply:IsValid() or not ply:IsPlayer() then
        self:GetParent().TargetSize = self:GetParent().Small

        return
    end

    self.total:SetText(timeToStr(ply:GetUTime() + CurTime() - ply:GetUTimeStart()))
    self.session:SetText(timeToStr(CurTime() - ply:GetUTimeStart()))

    local nick = ply.GetBystanderName and ply:GetBystanderName() or ply:Nick()
    self.nick:SetText(nick)
end

-----------------------------------------------------------
--	 Name: PerformLayout
-----------------------------------------------------------
function INFOPANEL:PerformLayout()
    self.lblNick:SetSize(52, 18)
    self.lblNick:SetPos(8, 0)
    self.lblNick:SetText("Jogador: ")
    self.lblTotalTime:SetSize(52, 18)
    self.lblTotalTime:SetPos(8, 18)
    self.lblTotalTime:SetText("Total: ")
    self.lblSessionTime:SetSize(52, 18)
    self.lblSessionTime:SetPos(8, 36)
    self.lblSessionTime:SetText("Sessão: ")
    self.nick:SetSize(self:GetWide() - 52, 18)
    self.nick:SetPos(52, 0)
    self.total:SetSize(self:GetWide() - 52, 18)
    self.total:SetPos(52, 18)
    self.session:SetSize(self:GetWide() - 52, 18)
    self.session:SetPos(52, 36)
end

-----------------------------------------------------------
--	 Name: Paint
-----------------------------------------------------------
function INFOPANEL:Paint()
    return true
end

vgui.Register("UTimePlayerInfo", INFOPANEL, "Panel")