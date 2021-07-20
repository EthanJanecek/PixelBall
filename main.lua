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
courtW = (centerX - offsetX) * 2
bounds = {minX = offsetX, maxX = offsetX + courtW, minY = 0, maxY = display.contentHeight}

hoopCenter = {x = centerX, y = conversionFactor * 5.5 * 20, radius = conversionFactor * 1.5 * 20}

startPositionsOffense = {
    {x = offsetX + 4, y = hoopCenter.y},
    {x = offsetX + courtW * .15, y = 180},
    {x = centerX, y = 220},
    {x = offsetX + courtW * .85, y = 180},
    {x = offsetX + courtW - 4, y = hoopCenter.y},
}

LeagueLib = require("Objects.league")
league = LeagueLib:createLeague()
league:createSchedule()
userTeam = ""

-- Game Details
score = {away=0, home=0}
gameDetails = {qtr=1, min=12, sec=0, shotClockMax=24, shotClock=24}

display.setStatusBar(display.HiddenStatusBar)

composer.gotoScene("Scenes.menu")