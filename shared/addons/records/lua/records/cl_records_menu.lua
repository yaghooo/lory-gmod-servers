function RECORDS:OpenPage(name, records, user)
    local page = vgui.Create("RecordsPage")
    page:SetData(name, records, user)
end

RecordsPage = {}

function RecordsPage:Init()
    self:SetSize(math.min(700, ScrW()), math.min(720, ScrH()))
end

function RecordsPage:SetData(name, records, user)
    local title = vgui.Create("DLabel", self)
    title:SetFont(THEME.Font.Coolvetica30)
    title:SetPos(20, 20)
    title:SetText("Top " .. name)
    title:SetSize(title:GetTextSize(), 30)
    title:SetColor(color_white)

    if records then
        local i = 1

        for k, v in pairs(records) do
            local item = vgui.Create("UserRecord", self)
            item:SetRecord(i, v)
            i = i + 1
        end
    end

    local item = vgui.Create("UserRecord", self)

    local selfBetter = vgui.Create("DLabel", self)
    selfBetter:SetFont(THEME.Font.Coolvetica30)
    selfBetter:SetPos(20, self:GetTall() - item:GetTall() - self.ContainerPadding * 3)
    selfBetter:SetText("Seu melhor")
    selfBetter:SetSize(selfBetter:GetTextSize(), 30)
    selfBetter:SetColor(color_white)

    item:SetRecord(nil, {
        Name = LocalPlayer():Nick(),
        Value = user
    })
end

vgui.Register("RecordsPage", RecordsPage, THEME.Component.Page)
UserRecord = {}

function UserRecord:Init()
    local parent = self:GetParent()
    self:SetSize(parent:GetWide() - parent.ContainerPadding * 2, 35)
end

function UserRecord:SetRecord(index, record)
    local parent = self:GetParent()

    if index then
        self:SetPos(parent.ContainerPadding, parent.ContainerPadding * 2 + self:GetTall() * (index - 1) + parent.ContainerPadding * index)
    else
        self:SetPos(parent.ContainerPadding, parent:GetTall() - self:GetTall() - parent.ContainerPadding)
    end

    local name = vgui.Create("DLabel", self)

    if index then
        name:SetText(index .. " - " .. record.Name)
    else
        name:SetText(record.Name)
    end

    name:SetPos(6, 6)
    name:SetSize(600, 30)
    name:SetFont(THEME.Font.Coolvetica28)

    local value = vgui.Create("DLabel", self)
    value:SetText(record.Value)
    value:Dock(RIGHT)
    value:SetFont(THEME.Font.Coolvetica28)
    value:SetSize(value:GetTextSize() + 5, 0)
end

function UserRecord:Paint(w, h)
    surface.SetDrawColor(THEME.Color.LightSecondary)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("UserRecord", UserRecord)