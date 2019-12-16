if SERVER then
    include "pointshop/sv_init.lua"
else
    include "pointshop/cl_init.lua"
end

PS:Initialize()
