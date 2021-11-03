-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
system.activate( "multitouch" )
local composer = require("composer")

conversionFactor = display.contentHeight / 940
offsetX = 240 - (330 / 2)
centerX = display.contentCenterX
centerY = display.contentCenterY
courtW = (centerX - offsetX) * 2
courtH = display.contentHeight
bounds = {minX = offsetX, maxX = offsetX + courtW, minY = 0, maxY = display.contentHeight}
feetToPixels = 20

hoopCenter = {x = centerX, y = conversionFactor * 5.5 * feetToPixels, radius = conversionFactor * 1.5 * feetToPixels}

require("Constants.start_positions")
LeagueLib = require("Objects.league")
league = LeagueLib:createLeague()
league:createSchedule()
userTeam = ""

-- Game Details
minutesInQtr = 12
score = {away=0, home=0}
gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
gameInProgress = true
lineupSwitch = {-1, -1}

display.setStatusBar(display.HiddenStatusBar)
composer.gotoScene("Scenes.menu")
