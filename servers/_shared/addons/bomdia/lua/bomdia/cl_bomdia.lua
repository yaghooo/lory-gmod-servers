net.Receive("write_chat", function()
    local parse = util.JSONToTable(net.ReadString())
    local cabuloso = net.ReadBit()
    chat.AddText(unpack(parse))

    if cabuloso == 1 then
        surface.PlaySound("ambient/explosions/exp1.wav")
    end
end)