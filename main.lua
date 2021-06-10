-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require("composer")

startPositionsOffense = {
    {x = 0, y = 0},
    {x = 10, y = 10},
    {x = 20, y = 20},
    {x = 30, y = 30},
    {x = 40, y = 40},
}

LeagueLib = require("Objects.league")
league = LeagueLib:createLeague()
league:createSchedule()
userTeam = ""

display.setStatusBar(display.HiddenStatusBar)

composer.gotoScene("Scenes.menu")