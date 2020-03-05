net.Receive("chattext_msg", function(len)
    local table_insert = table.insert
    local msgs = {}

    while net.ReadBool() do
        local str = net.ReadString()
        local col = net.ReadVector()
        table_insert(msgs, Color(col.x, col.y, col.z))
        table_insert(msgs, str)
    end

    chat.AddText(unpack(msgs))
end)

net.Receive("msg_clients", function(len)
    local lines = {}

    while net.ReadBool() do
        local r = net.ReadUInt(8)
        local g = net.ReadUInt(8)
        local b = net.ReadUInt(8)
        local text = net.ReadString()

        table.insert(lines, {
            color = Color(r, g, b),
            text = text
        })
    end

    for _, line in pairs(lines) do
        MsgC(line.color, line.text)
    end
end)