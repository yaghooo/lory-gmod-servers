surface.CreateFont("MersRadialMedium", {
    font = "coolvetica",
    size = 36
})

local function drawTextShadow(t, f, x, y, c, px, py)
    color_black.a = c.a
    draw.SimpleText(t, f, x + 1, y + 1, color_black, px, py)
    draw.SimpleText(t, f, x, y, c, px, py)
    color_black.a = 255
end

function murderTimer.displayTimer()
    local totalTime = net.ReadInt(32)
    murderTimer.counter = net.ReadInt(32)
    local colorOfText = murderTimer.textColor
    local time = totalTime - murderTimer.counter

    timer.Create("murderRoundTimer", 1, totalTime - murderTimer.counter, function()
        -- Time client sync
        murderTimer.counter = murderTimer.counter + 1
        time = totalTime - murderTimer.counter

        if murderTimer.criticalTimeLeft(totalTime, time) then
            colorOfText = murderTimer.critialTimeColor
            surface.PlaySound("buttons/blip1.wav")
        elseif murderTimer.dangerTimeLeft(totalTime, time) then
            colorOfText = murderTimer.dangerTimeColor
        elseif murderTimer.warningTimeLeft(totalTime, time) then
            colorOfText = murderTimer.warningTimeColor
        end
    end)

    hook.Add("HUDPaint", "MurderTimer", function()
        draw.RoundedBoxEx(8, (ScrW() / 2) - 40, ScrH() - 35, 80, 35, murderTimer.backgroundColor, true, true, false, false)
        drawTextShadow(string.ToMinutesSeconds(time), "MersRadialMedium", ScrW() / 2, ScrH() - 30, colorOfText, TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)
    end)
end

net.Receive("startTheTimer", murderTimer.displayTimer)

net.Receive("stopTheTimer", function()
    timer.Stop("murderRoundTimer")
    hook.Remove("HUDPaint", "MurderTimer")
end)

net.Receive("toggleTheTimer", function()
    timer.Toggle("murderRoundTimer")
end)