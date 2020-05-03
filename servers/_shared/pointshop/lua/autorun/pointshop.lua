include("pointshop/sh_init.lua")
include("pointshop/sh_config.lua")

if SERVER then
    include("pointshop/providers/sqlite.lua")
    include("pointshop/sv_init.lua")
    include("pointshop/sv_player.lua")
    include("pointshop/sv_player_extension.lua")

    AddCSLuaFile("pointshop/cl_init.lua")
    AddCSLuaFile("pointshop/cl_player_extension.lua")
    AddCSLuaFile("pointshop/sh_config.lua")
    AddCSLuaFile("pointshop/sh_init.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopColorChooser.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopGivePoints.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopGiveItem.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopItem.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopMenu.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopPreview.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopUnbox.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopUnboxItem.lua")
    AddCSLuaFile("pointshop/vgui/DPointShopBodygroupChooser.lua")
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