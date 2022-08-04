-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
system.activate( "multitouch" )
local composer = require("composer")

math.randomseed(os.time())
androidDirectory = '/storage/emulated/0/Documents/save.json'

function getSaveDirectory()
    local path = system.pathForFile("save.json", system.DocumentsDirectory)

    if(string.find(path, "/data/user")) then
        return androidDirectory
    else
        return path
    end
end

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
league = nil
userTeam = ""

-- Game Details
minutesInQtr = 12
score = {away=0, home=0}
gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
gameInProgress = true
lineupSwitch = {-1, -1}
showingUserTeamStats = true
defensiveStrategy = 1
defenseStats = {}

qtrScores = {}

display.setStatusBar(display.HiddenStatusBar)
composer.gotoScene("Scenes.menu")
