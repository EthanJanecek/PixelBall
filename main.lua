-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local composer = require("composer")

LeagueLib = require("Objects.league")
league = LeagueLib:createLeague()
league:createSchedule()
userTeam = ""

display.setStatusBar(display.HiddenStatusBar)

composer.gotoScene("Scenes.menu")