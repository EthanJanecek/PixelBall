
local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil
local new = true

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function newGame(num)
    currentSaveFile = getSaveDirectory(num)
    composer.gotoScene("Scenes.settings")
end

local function loadGame(num)
    currentSaveFile = getSaveDirectory(num)
    league = LeagueLib:createFromSave(num)
    composer.gotoScene("Scenes.pregame")
end

local function displaySave(num)
    local function choose()
        if(new) then
            newGame(num)
        else
            loadGame(num)
        end
    end

    local details = LeagueLib:getSaveDetails(num)

    if(details) then
        local playoffStr = ""
        if(not details.regularSeason) then
            playoffStr = "Playoff "
        end
        local str = details.team .. "\n" .. playoffStr .. "Week " .. details.week .. "\nYear " ..details.year

        if(new) then
            createButtonWithBorder(sceneGroup, str, 18, display.contentWidth * (num / 4), display.contentCenterY, 4, TEXT_COLOR, RED, TRANSPARENT, choose)
        else
            createButtonWithBorder(sceneGroup, str, 18, display.contentWidth * (num / 4), display.contentCenterY, 4, TEXT_COLOR, RED, TRANSPARENT, choose)
        end
    else
        local str = "Empty"

        if(new) then
            createButtonWithBorder(sceneGroup, str, 18, display.contentWidth * (num / 4), display.contentCenterY, 4, TEXT_COLOR, RED, TRANSPARENT, choose)
        else
            createButtonWithBorder(sceneGroup, str, 18, display.contentWidth * (num / 4), display.contentCenterY, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nil)
        end
    end
    
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view
    new = event.params.new

	-- Code here runs when the scene is first created but has not yet appeared on screen	
	local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    for i = 1, 3 do
        displaySave(i)
    end
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
