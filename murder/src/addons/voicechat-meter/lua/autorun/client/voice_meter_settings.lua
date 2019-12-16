VoiceChatMeter = {}
VoiceChatMeter.SizeX = 250 -- The width for voice chat
VoiceChatMeter.SizeY = 40 -- The height for voice chat
VoiceChatMeter.FontSize = 17 -- The font size for player names on the voice chat
VoiceChatMeter.Radius = 4 -- How round you want the voice chat square to be (0 = square)
VoiceChatMeter.FadeAm = .1 -- How fast the voice chat square fades in and out. 1 = Instant, .01 = fade in really slow
VoiceChatMeter.SlideOut = true -- Should the chat meter do a "slide out" animation
VoiceChatMeter.SlideTime = .1 -- How much time it takes for voice chat box to "slide out" (if above is on)
-- A bit more advanced options
VoiceChatMeter.PosX = .97 -- The position based on your screen width for voice chat box. Choose between 0 and 1
VoiceChatMeter.PosY = .76 -- The position based on screen height for the voice chat box. Choose between 0 and 1
VoiceChatMeter.Align = 0 -- How should the voice chat align? For align right, choose 0. For align left, choose 1
VoiceChatMeter.StackUp = true -- If more people up, should the voice chat boxes go upwards?

VoiceChatMeter.MemberColors = {
    {
        Rank = {"self"},
        Color = Color(0, 80, 80)
    },
    {
        Rank = {"vip"},
        Color = Color(220, 180, 0)
    },
    {
        Rank = {"admin"},
        Color = Color(200, 0, 0)
    },
    {
        Rank = {"superadmin", "subdono"},
        Color = Color(0, 0, 0)
    }
}

include("voicemeter/cl_voice_meter.lua")