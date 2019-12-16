-- Config
murderTimer = {}
murderTimer.counter = 0
-- Color of the timer's regular text
murderTimer.textColor = Color(255, 255, 255) -- 255 is the max color number. 0 is the least.
-- Color of the timer background
murderTimer.backgroundColor = Color(0, 0, 0, 150) -- The last number is for transparancy. 255 is solid. 0 is invisible
-- Color of the timer's text when the timer gets to the warning time
murderTimer.warningTimeColor = Color(255, 255, 0)
-- When the warning time color should be displayed. Default is half of the timer duration.
-- Ex. murderTimer.duration / 2 is half the timer duration. Or to set it in seconds: Ex. 300 is 5 minutes
murderTimer.warningTimeLeft = function(fulltime, time) return time <= fulltime / 2 end
-- Color of the timer's text when the timer gets to the danger time
murderTimer.dangerTimeColor = Color(255, 153, 0)
-- When the danger time color should be displayed. Default is a fifth of the timer duration.
-- Ex. murderTimer.duration / 5 is a fifth the timer duration. Or to set it in seconds: Ex. 120 is 2 minutes
murderTimer.dangerTimeLeft = function(fulltime, time) return time <= fulltime / 5 end
-- Color of the timer'd text when the timer gets to the critical time
murderTimer.critialTimeColor = Color(255, 0, 0)
-- When the critical time color should be displayed. Default is 10 seconds.
murderTimer.criticalTimeLeft = function(fulltime, time) return time <= 10 end