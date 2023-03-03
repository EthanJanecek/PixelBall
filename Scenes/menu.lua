local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
	local options = {
        params = {
            new=true
        }
    }

    composer.gotoScene("Scenes.saves", options)
end

local function doesSaveFileExist()
	for i = 1, 3 do
		local path = getSaveDirectory(i)
		local f = io.open(path, "r")

		if(f) then
			return true
		end
	end
	
	return false
end

local function loadOptions()
	local options = {
        params = {
            new=false
        }
    }

    composer.gotoScene("Scenes.saves", options)
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	local sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

	local title = display.newText(sceneGroup, "Pixel-Ball", display.contentCenterX, display.contentCenterY / 2, native.systemFont, 64)
    title:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

	createButtonWithBorder(sceneGroup, "New", 32, display.contentCenterX, display.contentCenterY, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)

	if(doesSaveFileExist()) then
		createButtonWithBorder(sceneGroup, "Load", 32, display.contentCenterX, display.contentCenterY * 1.3, 2, 
				TEXT_COLOR, TEXT_COLOR, TRANSPARENT, loadOptions)
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
