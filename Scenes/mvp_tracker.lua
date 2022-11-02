local composer = require( "composer" )

local scene = composer.newScene()
local sceneGroup = nil
local json = require( "json" )

local statPositions = {
    0,      -- Name
    .25,    -- Pts
    .35,     -- Win%
    .45,    -- 2PT%
    .55,   -- 3PT%
    .65,   -- TS%
    .75,     -- eFG%
    .85,     -- +/-
}

local fontSize = 12
local rowDist = 16
local paddingX = 8
local paddingY = 30

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
	composer.removeScene("Scenes.mvp_tracker")
    composer.gotoScene("Scenes.pregame")
end

local function sixthMan()
	composer.removeScene("Scenes.mvp_tracker")
    composer.gotoScene("Scenes.sixth_man_tracker")
end

local function roty()
	composer.removeScene("Scenes.mvp_tracker")
    composer.gotoScene("Scenes.roty_tracker")
end

local function dpoty()
	composer.removeScene("Scenes.mvp_tracker")
    composer.gotoScene("Scenes.dpoty_tracker")
end

local function drawHeaders()
    local name = display.newText(sceneGroup, "Name", display.contentWidth * statPositions[1] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, "Pts", display.contentWidth * statPositions[2] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local winPercent = display.newText(sceneGroup, "Win%", display.contentWidth * statPositions[3] + paddingX, 
                    paddingY, native.systemFont, fontSize)
                    winPercent:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, "2PT%", display.contentWidth * statPositions[4] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, "3PT%", display.contentWidth * statPositions[5] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, "TS%", display.contentWidth * statPositions[6] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, "eFG%", display.contentWidth * statPositions[7] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, "+/-", display.contentWidth * statPositions[8] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, paddingY + 4, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(.922, .910, .329)
    dividerHorizontal:setFillColor(.922, .910, .329)
end

local function drawPlayer(player, row)
    local name = display.newText(sceneGroup, player.name, display.contentWidth * statPositions[1] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, player.pts, display.contentWidth * statPositions[2] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local winPercent = display.newText(sceneGroup, player.winPercent, display.contentWidth * statPositions[3] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
                    winPercent:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, player.twoPtPercent, display.contentWidth * statPositions[4] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, player.threePtPercent, display.contentWidth * statPositions[5] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, player.ts, display.contentWidth * statPositions[6] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, player.eFG, display.contentWidth * statPositions[7] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, player.plusMinus, display.contentWidth * statPositions[8] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)
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

	createButtonWithBorder(sceneGroup, "<- Back", 16, 0, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)
    createButtonWithBorder(sceneGroup, "MVP", 16, display.contentWidth * .25, 8, 4, BLACK, DARK_BLUE, TRANSPARENT, nil)
    createButtonWithBorder(sceneGroup, "6MOTY", 16, display.contentWidth * .5, 8, 2, BLACK, BLACK, TRANSPARENT, sixthMan)
    createButtonWithBorder(sceneGroup, "ROTY", 16, display.contentWidth * .75, 8, 2, BLACK, BLACK, TRANSPARENT, roty)
    createButtonWithBorder(sceneGroup, "DPOTY", 16, display.contentWidth, 8, 2, BLACK, BLACK, TRANSPARENT, dpoty)

    drawHeaders()

    local players = {}

    for i = 1, #league.teams do
        local team = league.teams[i]
        local games = team.wins + team.losses

        if(games ~= 0) then
            for j = 1, #team.players do
                local player = team.players[j]
                local stats = player.yearStats
                local points = math.round(stats.points / games)
                local winPercent = math.round(team.wins * 100 / games)

                local twoPtPercent = 0
                if(stats.twoPA ~= 0) then
                    twoPtPercent = math.round(stats.twoPM * 100 / stats.twoPA)
                end
                
                local threePtPercent = 0
                if(stats.threePA ~= 0) then
                    threePtPercent = math.round(stats.threePM * 100 / stats.threePA)
                end

                local ts = 0
                local eFG = 0
                if(stats.twoPA + stats.threePA ~= 0) then
                    ts = math.round(stats.points * 100 / (2 * (stats.twoPA + stats.threePA)))
                    eFG = math.round((stats.twoPM + .5 * stats.threePM) * 100 / (stats.twoPA + stats.threePA))
                end

                local plusMinus = math.round(stats.plusMinus / games)
    
                -- normalize each stat from 0-10
                local rating = points + plusMinus + (winPercent / 20) + (twoPtPercent / 10) + (threePtPercent / 10) + (ts / 15) + (eFG / 15)
    
                local playerStats = {
                    name = player.name,
                    winPercent = winPercent,
                    pts = points,
                    twoPtPercent = twoPtPercent,
                    threePtPercent = threePtPercent,
                    ts = ts,
                    eFG = eFG,
                    plusMinus = plusMinus,
                    rating = rating
                }
    
                table.insert(players, playerStats)
            end
        end
    end

    table.sort(players, function(a, b)
        return a.rating > b.rating
    end)

    for i = 1, 15 do
        drawPlayer(players[i], i)
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
