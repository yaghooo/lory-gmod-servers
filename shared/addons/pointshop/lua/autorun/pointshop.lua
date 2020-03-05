include("pointshop/sh_init.lua")
include("pointshop/sh_config.lua")

if SERVER then
    include("pointshop/pointshop/sv_init.lua")
    include("pointshop/sv_player_extension.lua")
    include("pointshop/sv_manifest.lua")
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