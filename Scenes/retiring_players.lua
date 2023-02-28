local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    setUpDraft(league)
    composer.gotoScene("Scenes.draft")
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
    background:addEventListener("tap", nextScene)

	local title = display.newText(sceneGroup, "Retiring Players", display.contentCenterX, 16, native.systemFont, 24)
    title:setFillColor(.922, .910, .329)

    for i = 1, #league.teams do
        local team = league.teams[i]

        if(team.name == userTeam) then
            local j = #team.players
            local playersRetired = 0

            while j >= 1 do
                local player = team.players[j]

                if(player.years >= 18) then
                    local name = display.newText(sceneGroup, player.name, display.contentCenterX, 64 + (playersRetired * 20), native.systemFont, 24)
                    name:setFillColor(.922, .910, .329)
                    playersRetired = playersRetired + 1
                    table.remove(team.players, j)
                end

                j = j - 1
            end
        else
            retirePlayers(team)
        end
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
