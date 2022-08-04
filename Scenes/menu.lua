local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
	composer.removeScene("Scenes.menu")
    composer.gotoScene("Scenes.settings")
end

local function doesSaveFileExist()
	local path = getSaveDirectory()
	local f = io.open(path, "r")

	if(f) then
		return true
	else
		return false
	end
end

local function loadGame()
	league = LeagueLib:createFromSave()

	composer.removeScene("Scenes.menu")
    composer.gotoScene("Scenes.pregame")
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	local title = display.newText(sceneGroup, "Pixel-Ball", display.contentCenterX, display.contentCenterY / 2, native.systemFont, 64)
    title:setFillColor(.922, .910, .329)

    local playButton = display.newText(sceneGroup, "New", display.contentCenterX, display.contentCenterY, native.systemFont, 32)
    playButton:setFillColor(0, 0, 0)
    playButton:addEventListener("tap", nextScene)

	local buttonBorder = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, playButton.width, playButton.height)
	buttonBorder:setStrokeColor(0, 0, 0)
	buttonBorder.strokeWidth = 2
	buttonBorder:setFillColor(0, 0, 0, 0)
	buttonBorder:addEventListener("tap", nextScene)

	if(doesSaveFileExist()) then
		local continueButton = display.newText(sceneGroup, "Continue", display.contentCenterX, display.contentCenterY * 1.3, native.systemFont, 32)
		continueButton:setFillColor(0, 0, 0)
		continueButton:addEventListener("tap", loadGame)

		local continueButtonBorder = display.newRect(sceneGroup, continueButton.x, continueButton.y, continueButton.width, continueButton.height)
		continueButtonBorder:setStrokeColor(0, 0, 0)
		continueButtonBorder.strokeWidth = 2
		continueButtonBorder:setFillColor(0, 0, 0, 0)
		continueButtonBorder:addEventListener("tap", loadGame)
	end
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
