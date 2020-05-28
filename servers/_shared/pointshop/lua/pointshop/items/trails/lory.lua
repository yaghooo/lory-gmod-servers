ITEM.Name = "Lory"
ITEM.Price = 1000
ITEM.Material = "trails/lory.vmt"
ITEM.NoPreview = true

if SERVER then
    resource.AddFile("materials/" .. ITEM.Material)
end