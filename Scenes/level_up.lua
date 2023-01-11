local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local player = nil
local team = nil
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local options = {
        params = {
            team = team,
            player = player
        }
    }

    if(player.levels > 0) then
        composer.removeScene("Scenes.level_up")
        composer.gotoScene("Scenes.level_up", options)
    else
        composer.removeScene("Scenes.level_up")
        composer.gotoScene("Scenes.player_card", options)
    end
end

local function displayString(text, x, y)
    local label = display.newText(sceneGroup, text, x, y, native.systemFont, 16)
    label:setFillColor(.922, .910, .329)
end

local function displayAttributes()
    local y = 60
    if(player.finishing < 10) then
        createButtonWithBorder(sceneGroup, "Finishing: " .. player.finishing, 16, 0, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.finishing = player.finishing + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Finishing: " .. player.finishing, 0, y)
    end

    if(player.closeShot < 10) then
        createButtonWithBorder(sceneGroup, "Close Shot: " .. player.closeShot, 16, display.contentWidth * .33, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.closeShot = player.closeShot + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Close Shot: " .. player.closeShot, display.contentWidth * .33, y)
    end

    if(player.midRange < 10) then
        createButtonWithBorder(sceneGroup, "Mid-Range: " .. player.midRange, 16, display.contentWidth * .67, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.midRange = player.midRange + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Mid-Range: " .. player.midRange, display.contentWidth * .67, y)
    end

    if(player.three < 10) then
        createButtonWithBorder(sceneGroup, "3-PT: " .. player.three, 16, display.contentWidth, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.three = player.three + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("3-PT: " .. player.three, display.contentWidth, y)
    end

    y = y + 30
    if(player.dribbling < 10) then
        createButtonWithBorder(sceneGroup, "Dribbling: " .. player.dribbling, 16, 0, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.dribbling = player.dribbling + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Dribbling: " .. player.dribbling, 0, y)
    end

    if(player.stealing < 10) then
        createButtonWithBorder(sceneGroup, "Stealing: " .. player.stealing, 16, display.contentWidth * .5, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.stealing = player.stealing + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Stealing: " .. player.stealing, display.contentWidth * .5, y)
    end

    if(player.blocking < 10) then
        createButtonWithBorder(sceneGroup, "Blocking: " .. player.blocking, 16, display.contentWidth, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.blocking = player.blocking + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Blocking: " .. player.blocking, display.contentWidth, y)
    end

    y = y + 30
    if(player.contestingInterior < 10) then
        createButtonWithBorder(sceneGroup, "Interior Defending: " .. player.contestingInterior, 16, display.contentWidth * .25, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.contestingInterior = player.contestingInterior + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Interior Defending: " .. player.contestingInterior, 0, y)
    end

    if(player.contestingExterior < 10) then
        createButtonWithBorder(sceneGroup, "Exterior Defending: " .. player.contestingExterior, 16, display.contentWidth * .75, y, 2, YELLOW, YELLOW, TRANSPARENT, 
                function ()
                    player.contestingExterior = player.contestingExterior + 1
                    player.levels = player.levels - 1
                    nextScene()
                end
            )
    else
        displayString("Exterior Defending: " .. player.contestingExterior, display.contentWidth * .5, y)
    end
end

local function showPlayer()
    -- Number + Name
    local nameStr = "#" .. player.number .. " - " .. player.name
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 20, native.systemFont, 24)
    startersLabel:setFillColor(.922, .910, .329)

    -- Attributes
    displayAttributes()
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    player = event.params.player
    team = event.params.team

    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    showPlayer()
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
