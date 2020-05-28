DR = {}

if SERVER then
    --convars
    AddCSLuaFile("cl_convars.lua")
    include("sv_convars.lua")
    -- base
    AddCSLuaFile("cl_hud.lua")
    AddCSLuaFile("cl_init.lua")
    AddCSLuaFile("cl_menus.lua")
    AddCSLuaFile("shared.lua")
    AddCSLuaFile("config.lua")
    AddCSLuaFile("sh_init.lua")
    include("config.lua")
    include("shared.lua")
    -- scoreboard
    AddCSLuaFile("cl_scoreboard.lua")
    -- commands
    include("sv_commands.lua")
    -- Round System
    AddCSLuaFile("roundsystem/sh_round.lua")
    AddCSLuaFile("roundsystem/cl_round.lua")
    AddCSLuaFile("sh_definerounds.lua")
    include("roundsystem/sh_round.lua")
    include("roundsystem/sv_round.lua")
    include("sh_definerounds.lua")
    -- zones
    AddCSLuaFile("zones/sh_zone.lua")
    AddCSLuaFile("zones/cl_zone.lua")
    include("zones/sh_zone.lua")
    include("zones/sv_zone.lua")
    --player
    include("sv_player.lua")
    --button claiming
    include("sh_buttonclaiming.lua")
    AddCSLuaFile("sh_buttonclaiming.lua")
    -- pointshop support
    include("sv_pointshopsupport.lua")
    -- statistics
    include("sv_statistics.lua")
    AddCSLuaFile("cl_statistics.lua")
else
    include("config.lua")
    include("shared.lua")
    include("cl_scoreboard.lua")
    include("roundsystem/sh_round.lua")
    include("roundsystem/cl_round.lua")
    include("sh_definerounds.lua")
    include("zones/sh_zone.lua")
    include("zones/cl_zone.lua")
    include("cl_hud.lua")
    include("cl_menus.lua")
    include("sh_buttonclaiming.lua")
    include("cl_statistics.lua")
    include("cl_convars.lua")
end