local composer = require( "composer" )
local scene = composer.newScene()
local sceneGroup = nil

local fontSize = 24
local leagueStarted = false

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function applyChanges()
	if(numGamesSetting == 1) then
		games = 29
		numDays = 100
	elseif(numGamesSetting == 2) then
		games = 58
		numDays = 150
	else
		games = 72
		numDays = 200
	end

	if(difficultySetting == 1) then
		difficulty = 1
	elseif(difficultySetting == 2) then
		difficulty = 2
	else
		difficulty = 3
	end

	if(minutesInQtrSetting == 1) then
		minutesInQtr = 4
	elseif(minutesInQtrSetting == 2) then
		minutesInQtr = 8
	else
		minutesInQtr = 12
	end
end

local function nextScene()
	applyChanges()
	league = LeagueLib:createLeague()
	league:createSchedule()

    composer.gotoScene("Scenes.team_selection")
end

local function back()
	applyChanges()
    composer.gotoScene("Scenes.pregame")
end

local function redraw()
	local options = {
        params = {
            leagueStarted = leagueStarted
        }
    }

    composer.gotoScene("Scenes.load_scene", options)
end

local function displayNumGamesSetting(i)
	local function selectNumGames()
		numGamesSetting = i
		redraw()
	end

	local str = ""
	if(i == 1) then
		str = "29"
	elseif(i == 2) then
		str = "58"
	else
		str = "72"
	end

	local option = display.newText(sceneGroup, str, display.contentWidth * (i * 2) / 6, display.contentHeight / 5, native.systemFont, fontSize)
    option:setFillColor(.922, .910, .329)

	local optionBorder = display.newRect(sceneGroup, option.x, option.y, option.width, option.height)
    optionBorder:setFillColor(0, 0, 0, 0)

	if(numGamesSetting == i) then
        optionBorder:setStrokeColor(0, 0, 1)
        optionBorder.strokeWidth = 4
    else
        optionBorder:setStrokeColor(.922, .910, .329)
        optionBorder.strokeWidth = 2
    end

	if(not leagueStarted) then
		option:addEventListener("tap", selectNumGames)
		optionBorder:addEventListener("tap", selectNumGames)
	end
end

local function numGames()
	local str = display.newText(sceneGroup, "Number of Games: ", 0, display.contentHeight / 5, native.systemFont, fontSize)
    str:setFillColor(.922, .910, .329)

	for i = 1, 3 do
		displayNumGamesSetting(i)
	end
end

local function displayDifficultySetting(i)
	local function selectDifficulty()
		difficultySetting = i
		redraw()
	end

	local str = ""
	if(i == 1) then
		str = "Normal"
	elseif(i == 2) then
		str = "Hard"
	else
		str = "Extreme"
	end

	local option = display.newText(sceneGroup, str, display.contentWidth * (i * 2) / 6, display.contentHeight * 2 / 5, native.systemFont, fontSize)
    option:setFillColor(.922, .910, .329)
    option:addEventListener("tap", selectDifficulty)

	local optionBorder = display.newRect(sceneGroup, option.x, option.y, option.width, option.height)
    optionBorder:setFillColor(0, 0, 0, 0)
    optionBorder:addEventListener("tap", selectDifficulty)

	if(difficultySetting == i) then
        optionBorder:setStrokeColor(0, 0, 1)
        optionBorder.strokeWidth = 4
    else
        optionBorder:setStrokeColor(.922, .910, .329)
        optionBorder.strokeWidth = 2
    end
end

local function difficulty()
	local str = display.newText(sceneGroup, "Difficulty: ", 0, display.contentHeight * 2 / 5, native.systemFont, fontSize)
    str:setFillColor(.922, .910, .329)

	for i = 1, 3 do
		displayDifficultySetting(i)
	end
end

local function displayMinutesInQuarterSetting(i)
	local function selectMinutes()
		minutesInQtrSetting = i
		redraw()
	end

	local str = ""
	if(i == 1) then
		str = "4"
	elseif(i == 2) then
		str = "8"
	else
		str = "12"
	end

	local option = display.newText(sceneGroup, str, display.contentWidth * (i * 2) / 6, display.contentHeight * 3 / 5, native.systemFont, fontSize)
    option:setFillColor(.922, .910, .329)
    option:addEventListener("tap", selectMinutes)

	local optionBorder = display.newRect(sceneGroup, option.x, option.y, option.width, option.height)
    optionBorder:setFillColor(0, 0, 0, 0)
    optionBorder:addEventListener("tap", selectMinutes)

	if(minutesInQtrSetting == i) then
        optionBorder:setStrokeColor(0, 0, 1)
        optionBorder.strokeWidth = 4
    else
        optionBorder:setStrokeColor(.922, .910, .329)
        optionBorder.strokeWidth = 2
    end
end

local function minutesInQuarter()
	local str = display.newText(sceneGroup, "Minutes per Quarter: ", 0, display.contentHeight * 3 / 5, native.systemFont, fontSize)
    str:setFillColor(.922, .910, .329)

	for i = 1, 3 do
		displayMinutesInQuarterSetting(i)
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	if(event.params and event.params.leagueStarted) then
		leagueStarted = true
		createButtonWithBorder(sceneGroup, "Apply", fontSize, display.contentCenterX, display.contentHeight * .8, 2, 
				BLACK, BLACK, TRANSPARENT, back)
	else
		createButtonWithBorder(sceneGroup, "Choose Team", fontSize, display.contentCenterX, display.contentHeight * .8, 2, 
				BLACK, BLACK, TRANSPARENT, nextScene)
	end

	numGames()
	difficulty()
	minutesInQuarter()
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		local previous = composer.getSceneName("previous")
		composer.removeScene(previous)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
