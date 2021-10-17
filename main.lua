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
feetToPixels = 20

hoopCenter = {x = centerX, y = conversionFactor * 5.5 * feetToPixels, radius = conversionFactor * 1.5 * feetToPixels}

startPositionsOffense = {
    {x = offsetX + 4, y = hoopCenter.y},
    {x = offsetX + courtW * .15, y = 180},
    {x = centerX, y = 220},
    {x = offsetX + courtW * .85, y = 180},
    {x = offsetX + courtW - 4, y = hoopCenter.y},
}

startPositionsDefense = {
    {x = offsetX + 40, y = hoopCenter.y},
    {x = offsetX + courtW * .2, y = 160},
    {x = centerX, y = 180},
    {x = offsetX + courtW * .8, y = 160},
    {x = offsetX + courtW - 40, y = hoopCenter.y},
}

LeagueLib = require("Objects.league")
league = LeagueLib:createLeague()
league:createSchedule()
userTeam = ""

-- Game Details
score = {away=0, home=0}
gameDetails = {qtr=1, min=12, sec=0, shotClock=24}
gameInProgress = true

display.setStatusBar(display.HiddenStatusBar)

composer.gotoScene("Scenes.menu")
