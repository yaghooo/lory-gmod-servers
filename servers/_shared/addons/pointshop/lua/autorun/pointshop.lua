include("pointshop/sh_init.lua")
include("pointshop/sh_config.lua")

if SERVER then
    include("pointshop/pointshop/sv_init.lua")
    include("pointshop/sv_player_extension.lua")

    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("cl_player_extension.lua")
    AddCSLuaFile("sh_config.lua")
    AddCSLuaFile("sh_init.lua")
    AddCSLuaFile("vgui/DPointShopColorChooser.lua")
    AddCSLuaFile("vgui/DPointShopGivePoints.lua")
    AddCSLuaFile("vgui/DPointShopGiveItem.lua")
    AddCSLuaFile("vgui/DPointShopItem.lua")
    AddCSLuaFile("vgui/DPointShopMenu.lua")
    AddCSLuaFile("vgui/DPointShopPreview.lua")
    AddCSLuaFile("vgui/DPointShopUnbox.lua")
    AddCSLuaFile("vgui/DPointShopUnboxItem.lua")
    AddCSLuaFile("vgui/DPointShopBodygroupChooser.lua")
else
    include("pointshop/cl_init.lua")
    include("pointshop/cl_player_extension.lua")
    include("pointshop/vgui/DPointShopMenu.lua")
    include("pointshop/vgui/DPointShopItem.lua")
    include("pointshop/vgui/DPointShopPreview.lua")
    include("pointshop/vgui/DPointShopUnbox.lua")
    include("pointshop/vgui/DPointShopUnboxItem.lua")
    include("pointshop/vgui/DPointShopColorChooser.lua")
    include("pointshop/vgui/DPointShopGivePoints.lua")
    include("pointshop/vgui/DPointShopGiveItem.lua")
    include("pointshop/vgui/DPointShopBodygroupChooser.lua")
end

if PS then
    PS:Initialize()
else
    error("Failed to load pointshop, probably has an error above")
end