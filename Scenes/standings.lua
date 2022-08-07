local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil
local json = require( "json" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local prevScene = composer.getSceneName( "previous" )
	composer.removeScene("Scenes.standings")
    composer.gotoScene(prevScene)
end

local function findMax(teams, startIndex)
    local maxPercent = -1
    local maxWins = -1
    local maxIndex = -1


    for i = startIndex, 15 do
        local totalGames = teams[i].wins + teams[i].losses
        local percent = 0

        if(totalGames ~= 0) then
            percent = teams[i].wins * 1.0 / (teams[i].wins + teams[i].losses)
        end

        if(percent > maxPercent) then
            maxPercent = percent
            maxWins = teams[i].wins
            maxIndex = i
        elseif(percent == maxPercent and teams[i].wins > maxWins) then
            maxPercent = percent
            maxWins = teams[i].wins
            maxIndex = i
        end
    end

    return maxIndex
end

local function getEastTeams()
    local eastTeams = {}
    local num = 1

    for i = 1, #league.teams do
        local team = league.teams[i]
        if(team.conf == "East") then
            eastTeams[num] = team
            num = num + 1
        end
    end

    for i = 1, 15 do
        local max = findMax(eastTeams, i)
        local temp = eastTeams[max]
        eastTeams[max] = eastTeams[i]
        eastTeams[i] = temp
    end

    return eastTeams
end

local function getWestTeams()
    local westTeams = {}
    local num = 1

    for i = 1, #league.teams do
        local team = league.teams[i]
        if(team.conf == "West") then
            westTeams[num] = team
            num = num + 1
        end
    end
    
    for i = 1, 15 do
        local max = findMax(westTeams, i)
        local temp = westTeams[max]
        westTeams[max] = westTeams[i]
        westTeams[i] = temp
    end

    return westTeams
end

local function drawHeaders()
    local westLabel = display.newText(sceneGroup, "West", display.contentCenterX * .5, 20, native.systemFont, 24)
    westLabel:setFillColor(.922, .910, .329)

    local eastLabel = display.newText(sceneGroup, "East", display.contentCenterX * 1.25, 20, native.systemFont, 24)
    eastLabel:setFillColor(.922, .910, .329)

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, 32, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(.922, .910, .329)
    dividerHorizontal:setFillColor(.922, .910, .329)
end

local function drawTeam(team, row)
    local padding = 24
    if(team.conf == "West") then
        local name = display.newText(sceneGroup, team.name, display.contentCenterX * .5, 16 * row + padding, native.systemFont, 12)
        name:setFillColor(.922, .910, .329)

        local recordStr = "(" .. team.wins .. "-" .. team.losses .. ")"
        local record = display.newText(sceneGroup, recordStr, display.contentCenterX * .75, 16 * row + padding, native.systemFont, 12)
        record:setFillColor(.922, .910, .329)
    else
        local name = display.newText(sceneGroup, team.name, display.contentCenterX * 1.25, 16 * row + padding, native.systemFont, 12)
        name:setFillColor(.922, .910, .329)

        local recordStr = "(" .. team.wins .. "-" .. team.losses .. ")"
        local record = display.newText(sceneGroup, recordStr, display.contentCenterX * 1.5, 16 * row + padding, native.systemFont, 12)
        record:setFillColor(.922, .910, .329)
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

	local playButton = display.newText(sceneGroup, "<- Back", 8, 8, native.systemFont, 16)
    playButton:setFillColor(0, 0, 0)
    playButton:addEventListener("tap", nextScene)

    local buttonBorder = display.newRect(sceneGroup, playButton.x, playButton.y, playButton.width, playButton.height)
    buttonBorder:setStrokeColor(0, 0, 0)
    buttonBorder.strokeWidth = 2
    buttonBorder:setFillColor(0, 0, 0, 0)
    buttonBorder:addEventListener("tap", nextScene)

    drawHeaders()
    local westTeams = getWestTeams()
    local eastTeams = getEastTeams()

    for i = 1, 15 do
        drawTeam(westTeams[i], i)
        drawTeam(eastTeams[i], i)
    end
end


-- show()
function scene:show( event )
    sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )
    sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

	end
end


-- destroy()
function scene:destroy( event )
    sceneGroup = self.view
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
