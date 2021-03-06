local composer = require( "composer" )
local json = require( "json" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function toGame()
    gameInProgress = true
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.game")
end

local function nextWeek()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.postgame")
end

local function changeLineup()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.lineup")
end

local function createPlays()
    composer.removeScene("Scenes.pregame")
    composer.gotoScene("Scenes.play_creation")
end

local function saveGame()
    local path = system.pathForFile( "save.json", system.DocumentsDirectory )
    local file, errorString = io.open(path, "w")
    
    if file then
        file:write(json.encode(league))
        io.close(file)
    else
        print(errorString)
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    lineupSwitch = {-1, -1}
    score = {away=0, home=0}
    gameDetails = {qtr=1, min=minutesInQtr, sec=0, shotClock=24}
    
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local allGames = league.schedule[league.weekNum]
    local gameInfo = league:findGameInfo(allGames, userTeam)

    if(gameInfo == nil) then
        local title = "Off Day"

        local title = display.newText(sceneGroup, title, display.contentCenterX, display.contentCenterY / 2, native.systemFont, 48)
        title:setFillColor(.922, .910, .329)

        local playButton = display.newText(sceneGroup, "Next Game", display.contentCenterX, display.contentCenterY, native.systemFont, 32)
        playButton:setFillColor(0, 0, 0)
        playButton:addEventListener("tap", nextWeek)

        local buttonBorder = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, playButton.width, playButton.height)
        buttonBorder:setStrokeColor(0, 0, 0)
        buttonBorder.strokeWidth = 2
        buttonBorder:setFillColor(0, 0, 0, 0)
        buttonBorder:addEventListener("tap", nextWeek)
    else
        local titleStr = gameInfo.away .. " vs. " .. gameInfo.home

        local title = display.newText(sceneGroup, titleStr, display.contentCenterX, display.contentCenterY / 2, native.systemFont, 48)
        title:setFillColor(.922, .910, .329)

        local playButton = display.newText(sceneGroup, "Play", display.contentCenterX, display.contentCenterY, native.systemFont, 32)
        playButton:setFillColor(0, 0, 0)
        playButton:addEventListener("tap", toGame)

        local buttonBorder = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, playButton.width, playButton.height)
        buttonBorder:setStrokeColor(0, 0, 0)
        buttonBorder.strokeWidth = 2
        buttonBorder:setFillColor(0, 0, 0, 0)
        buttonBorder:addEventListener("tap", toGame)

        local lineupButton = display.newText(sceneGroup, "Change Lineup", display.contentCenterX, display.contentCenterY * 1.3, native.systemFont, 32)
        lineupButton:setFillColor(0, 0, 0)
        lineupButton:addEventListener("tap", changeLineup)

        local lineupButtonBorder = display.newRect(sceneGroup, lineupButton.x, lineupButton.y, lineupButton.width, lineupButton.height)
        lineupButtonBorder:setStrokeColor(0, 0, 0)
        lineupButtonBorder.strokeWidth = 2
        lineupButtonBorder:setFillColor(0, 0, 0, 0)
        lineupButtonBorder:addEventListener("tap", changeLineup)

        local playCreationButton = display.newText(sceneGroup, "Create Plays", display.contentCenterX, display.contentCenterY * 1.6, native.systemFont, 32)
        playCreationButton:setFillColor(0, 0, 0)
        playCreationButton:addEventListener("tap", createPlays)

        local playCreationButtonBorder = display.newRect(sceneGroup, playCreationButton.x, playCreationButton.y, playCreationButton.width, playCreationButton.height)
        playCreationButtonBorder:setStrokeColor(0, 0, 0)
        playCreationButtonBorder.strokeWidth = 2
        playCreationButtonBorder:setFillColor(0, 0, 0, 0)
        playCreationButtonBorder:addEventListener("tap", createPlays)
    end

    local saveButton = display.newText(sceneGroup, "Save Game", 0, 20, native.systemFont, 32)
    saveButton:setFillColor(0, 0, 0)
    saveButton:addEventListener("tap", saveGame)

    local saveButtonBorder = display.newRect(sceneGroup, saveButton.x, saveButton.y, saveButton.width, saveButton.height)
    saveButtonBorder:setStrokeColor(0, 0, 0)
    saveButtonBorder.strokeWidth = 2
    saveButtonBorder:setFillColor(0, 0, 0, 0)
    saveButtonBorder:addEventListener("tap", saveGame)
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

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
