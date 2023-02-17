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

function indexOf(table, value)
    for i = 1, #table do
        if(table[i] == value) then
            return i
        end
    end

    return -1
end

function createButtonWithBorder(sceneGroup, text, fontSize, x, y, strokeWidth, textColor, strokeColor, fillColor, onClickFunction)
    local button = display.newText(sceneGroup, text, x, y, native.systemFont, fontSize)
    button:setFillColor(textColor[1], textColor[2], textColor[3], textColor[4])

    local buttonBorder = display.newRect(sceneGroup, button.x, button.y, button.width, button.height)
    buttonBorder:setStrokeColor(strokeColor[1], strokeColor[2], strokeColor[3], strokeColor[4])
    buttonBorder.strokeWidth = strokeWidth
    buttonBorder:setFillColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4])

    if(onClickFunction) then
        button:addEventListener("tap", onClickFunction)
        buttonBorder:addEventListener("tap", onClickFunction) 
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
require("Constants.colors")
require("Constants.name_generator")
require("Constants.streaks")
require("Constants.draft_players")
LeagueLib = require("Objects.league")
league = nil
userTeam = ""
lastScene = ""

-- Game Details
score = {away=0, home=0}
gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
gameInProgress = false
lineupSwitch = {-1, -1}
showingUserTeamStats = true
defensiveStrategy = 1
defenseStats = {}
simulateMainGame = false

regularSeason = true
playoffs = false
games = 72
numDays = 200
difficulty = 1
minutesInQtr = 12

draftRound = 1
draftPage = 1
cutPlayers = {}

numGamesSetting = 3
difficultySetting = 1
minutesInQtrSetting = 3

qtrScores = {}

display.setStatusBar(display.HiddenStatusBar)
composer.gotoScene("Scenes.menu")
