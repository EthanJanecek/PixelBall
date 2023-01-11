local composer = require("composer")

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    composer.gotoScene("Scenes.pregame")
end

local function showRoster(teamName)
    local options = {
        params = {
            team = league:findTeam(teamName)
        }
    }

    composer.gotoScene("Scenes.roster", options)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
    local sceneGroup = self.view
    local teams = league.teams
    local imageSize = 50
    local paddingX = 20
    local paddingY = 10

    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(.286, .835, .961)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local col = 0
	for i = 1, 30 do
        local row = (i - 1) % 5
        if((i - 1) % 5 == 0 and i ~= 1) then
            col = col + 1
        end
        
        local team = display.newImageRect(sceneGroup, teams[i].logo, imageSize, imageSize)
        team.x = (col * imageSize) + (col * paddingX) + paddingX
        team.y = (row * imageSize) + (row * paddingY) + (paddingY * 4)

        function chooseTeam()
            if(event.params and event.params.roster) then
                showRoster(teams[i].name)
            else
                userTeam = teams[i].name
                league.userTeam = userTeam
                nextScene()
            end
        end

        team:addEventListener("tap", chooseTeam)
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
