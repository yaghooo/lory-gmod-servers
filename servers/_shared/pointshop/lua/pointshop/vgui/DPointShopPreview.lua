local PANEL = {}

function PANEL:Init()
    self:SetCurrentModel()
    self.PrevMins, self.PrevMaxs = self.Entity:GetRenderBounds()
    self:SetCamPos(self.PrevMins:Distance(self.PrevMaxs) * Vector(0.30, 0.30, 0.25) + Vector(0, 0, 20))
    self:SetLookAt((self.PrevMaxs + self.PrevMins) / 2)
end

function PANEL:Paint()
    if not IsValid(self.Entity) then return end
    local x, y = self:LocalToScreen(0, 0)
    self:LayoutEntity(self.Entity)
    local ang = self.aLookAngle

    if not ang then
        ang = (self.vLookatPos - self.vCamPos):Angle()
    end

    local w, h = self:GetSize()
    cam.Start3D(self.vCamPos, ang, self.fFOV, x, y, w, h, 5, 4096)
    cam.IgnoreZ(true)
    render.SuppressEngineLighting(true)
    render.SetLightingOrigin(self.Entity:GetPos())
    render.ResetModelLighting(self.colAmbientLight.r / 255, self.colAmbientLight.g / 255, self.colAmbientLight.b / 255)
    render.SetColorModulation(self.colColor.r / 255, self.colColor.g / 255, self.colColor.b / 255)
    render.SetBlend(self.colColor.a / 255)

    for i = 0, 6 do
        local col = self.DirectionalLight[i]

        if col then
            render.SetModelLighting(i, col.r / 255, col.g / 255, col.b / 255)
        end
    end

    self.Entity:DrawModel()
    self:DrawOtherModels()

    function self.Entity:GetPlayerColor()
        return LocalPlayer():GetPlayerColor()
    end

    render.SuppressEngineLighting(false)
    cam.IgnoreZ(false)
    cam.End3D()
    self.LastPaint = RealTime()
end

function PANEL:DrawOtherModels()
    local ply = LocalPlayer()
    local ITEM = PS.HoverModel and PS.Items[PS.HoverModel]

    if (not ITEM or not ITEM.WeaponClass) and PS.ClientsideModels[ply] then
        for item_id, model in pairs(PS.ClientsideModels[ply]) do
            local modelItem = PS.Items[item_id]

            if modelItem.Attachment or modelItem.Bone then
                local pos = Vector()
                local ang = Angle()

                if modelItem.Attachment then
                    local attach_id = self.Entity:LookupAttachment(modelItem.Attachment)
                    if not attach_id then return end
                    local attach = self.Entity:GetAttachment(attach_id)
                    if not attach then return end
                    pos = attach.Pos
                    ang = attach.Ang
                else
                    local bone_id = self.Entity:LookupBone(modelItem.Bone)
                    if not bone_id then return end
                    pos, ang = self.Entity:GetBonePosition(bone_id)
                end

                model, pos, ang = modelItem:ModifyClientsideModel(ply, model, pos, ang)
                model:SetRenderOrigin(pos)
                model:SetRenderAngles(ang)
                model:SetupBones()
                model:DrawModel()
            else
                PS.ClientsideModels[ply][item_id] = nil
            end
        end
    end

    self:SetFOV(60)
    self:SetCamPos(self.PrevMins:Distance(self.PrevMaxs) * Vector(0.30, 0.30, 0.25) + Vector(0, 0, 20))
    self:SetLookAt((self.PrevMaxs + self.PrevMins) / 2)

    if ITEM then
        if ITEM.NoPreview then return end -- don't show

        -- must be a playermodel?
        if not ITEM.Attachment and not ITEM.Bone then
            self:SetModel(ITEM.Model)

            if ITEM.WeaponClass then
                self:GetEntity():SetSkin(ITEM.Skin or 0)
                self:GetEntity():SetMaterial(ITEM.PaintMaterial or nil)
                self:SetFOV(50)
                self:SetCamPos(self.PrevMins:Distance(self.PrevMaxs) * Vector() + Vector(0, 25, 0))
                self:SetLookAt((self.PrevMaxs + self.PrevMins) / 2 + Vector(0, -25, 0))
            end
        else
            local model = PS.HoverModelClientsideModel
            local pos = Vector()
            local ang = Angle()

            if ITEM.Attachment then
                local attach_id = self.Entity:LookupAttachment(ITEM.Attachment)
                if not attach_id then return end
                local attach = self.Entity:GetAttachment(attach_id)
                if not attach then return end
                pos = attach.Pos
                ang = attach.Ang
            else
                local bone_id = self.Entity:LookupBone(ITEM.Bone)
                if not bone_id then return end
                pos, ang = self.Entity:GetBonePosition(bone_id)
            end

            model, pos, ang = ITEM:ModifyClientsideModel(ply, model, pos, ang)
            model:SetPos(pos)
            model:SetAngles(ang)
            model:DrawModel()
        end
    else
        self:SetCurrentModel()
    end
end

function PANEL:SetCurrentModel()
    local ply = LocalPlayer()
    self:SetModel(ply:GetModel())
    self.Entity:SetSkin(ply:GetSkin())

    for _, v in pairs(ply:GetBodyGroups()) do
        self.Entity:SetBodygroup(v.id, ply:GetBodygroup(v.id))
    end
end

vgui.Register("DPointShopPreview", PANEL, "DModelPanel")