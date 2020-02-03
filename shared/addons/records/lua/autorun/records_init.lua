AddCSLuaFile("records/cl_records.lua")
AddCSLuaFile("records/cl_records_menu.lua")

RECORDS = {}
RECORDS.__index = RECORDS;

if CLIENT then
    include("records/cl_records.lua")
    include("records/cl_records_menu.lua")
else
    include("records/sv_records.lua")
    RECORDS:LoadRecords()
end