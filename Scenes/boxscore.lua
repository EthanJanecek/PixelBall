local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil

local statPositions = {
    0,      -- Name
    .25,    -- Pts
    .35,    -- 2PM
    .425,     -- 2PA
    .525,    -- 3PM
    .6,    -- 3PA
    .7,      -- BLK
    .8,      -- STL
    .9,       -- TRV
    1       -- +/-
}

local fontSize = 12
local rowDist = 16
local paddingX = 8
local paddingY = 70

local qtrWidth = 30
local qtrOffsetPercent = .5

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    composer.gotoScene("Scenes.postgame")
end

local function switchTeam()
    showingUserTeamStats = not showingUserTeamStats
    composer.gotoScene("Scenes.load_scene")
end

local function displayQtrBreakdownHeader()
    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent, 4, qtrWidth, 2)
    dividerHorizontal:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal2 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent, 25 + 4, qtrWidth, 2)
    dividerHorizontal2:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal2:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal3 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent, 50 + 4, qtrWidth, 2)
    dividerHorizontal3:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal3:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    if(userIsHome) then
        local awayName = display.newText(sceneGroup, opponent.abbrev, display.contentCenterX * qtrOffsetPercent, 6 + fontSize / 2, native.systemFont, fontSize)
        awayName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        local homeName = display.newText(sceneGroup, team.abbrev, display.contentCenterX * qtrOffsetPercent, 31 + fontSize / 2, native.systemFont, fontSize)
        homeName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    else
        local homeName = display.newText(sceneGroup, team.abbrev, display.contentCenterX * qtrOffsetPercent, 6 + fontSize / 2, native.systemFont, fontSize)
        homeName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

        local awayName = display.newText(sceneGroup, opponent.abbrev, display.contentCenterX * qtrOffsetPercent, 31 + fontSize / 2, native.systemFont, fontSize)
        awayName:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    end

    local awayScore = display.newText(sceneGroup, score.away, display.contentCenterX * qtrOffsetPercent + qtrWidth, 6 + fontSize / 2, native.systemFont, fontSize)
    awayScore:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local homeScore = display.newText(sceneGroup, score.home, display.contentCenterX * qtrOffsetPercent + qtrWidth, 31 + fontSize / 2, native.systemFont, fontSize)
    homeScore:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerVertical = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent - (qtrWidth / 2), (50 + 6) / 2, 2, 50)
    dividerVertical:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerVertical:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerVertical2 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth - (qtrWidth / 2), (50 + 6) / 2, 2, 50)
    dividerVertical2:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerVertical2:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerVertical3 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth * 2 - (qtrWidth / 2), (50 + 6) / 2, 4, 50)
    dividerVertical3:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerVertical3:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal4 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth, 4, qtrWidth, 2)
    dividerHorizontal4:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal4:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal5 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth, 25 + 4, qtrWidth, 2)
    dividerHorizontal5:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal5:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal6 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth, 50 + 4, qtrWidth, 2)
    dividerHorizontal6:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal6:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayQtrBreakdown(scores, i)
    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 1), 4, qtrWidth, 2)
    dividerHorizontal:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal2 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 1), 25 + 4, qtrWidth, 2)
    dividerHorizontal2:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal2:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal3 = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 1), 50 + 4, qtrWidth, 2)
    dividerHorizontal3:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal3:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local awayScore = display.newText(sceneGroup, scores[1], display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 1), 6 + fontSize / 2, native.systemFont, fontSize)
    awayScore:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local homeScore = display.newText(sceneGroup, scores[2], display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 1), 31 + fontSize / 2, native.systemFont, fontSize)
    homeScore:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerVertical = display.newRect(sceneGroup, display.contentCenterX * qtrOffsetPercent + qtrWidth * (i + 2) - (qtrWidth / 2), (50 + 6) / 2, 2, 50)
    dividerVertical:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerVertical:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function displayHeader()
    local name = display.newText(sceneGroup, "Name", display.contentWidth * statPositions[1] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    name:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local pts = display.newText(sceneGroup, "Pts", display.contentWidth * statPositions[2] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    pts:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPM = display.newText(sceneGroup, "2PM", display.contentWidth * statPositions[3] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPA = display.newText(sceneGroup, "2PA", display.contentWidth * statPositions[4] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePM = display.newText(sceneGroup, "3PM", display.contentWidth * statPositions[5] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePA = display.newText(sceneGroup, "3PA", display.contentWidth * statPositions[6] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local blocks = display.newText(sceneGroup, "BLK", display.contentWidth * statPositions[7] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    blocks:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local steals = display.newText(sceneGroup, "STL", display.contentWidth * statPositions[8] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    steals:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local turnovers = display.newText(sceneGroup, "TRV", display.contentWidth * statPositions[9] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local plusMinus = display.newText(sceneGroup, "+/-", display.contentWidth * statPositions[10] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, paddingY + 4, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
    dividerHorizontal:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end

local function showPlayerStats(player, row)
    local stats = player.stats[#player.stats]

    local name = display.newText(sceneGroup, player.name, display.contentWidth * statPositions[1] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    name:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local pts = display.newText(sceneGroup, stats.points, display.contentWidth * statPositions[2] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    pts:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPM = display.newText(sceneGroup, stats.twoPM, display.contentWidth * statPositions[3] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local twoPA = display.newText(sceneGroup, stats.twoPA, display.contentWidth * statPositions[4] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePM = display.newText(sceneGroup, stats.threePM, display.contentWidth * statPositions[5] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePM:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local threePA = display.newText(sceneGroup, stats.threePA, display.contentWidth * statPositions[6] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePA:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local blocks = display.newText(sceneGroup, stats.blocks, display.contentWidth * statPositions[7] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    blocks:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local steals = display.newText(sceneGroup, stats.steals, display.contentWidth * statPositions[8] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    steals:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local turnovers = display.newText(sceneGroup, stats.turnovers, display.contentWidth * statPositions[9] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])

    local plusMinus = display.newText(sceneGroup, stats.plusMinus, display.contentWidth * statPositions[10] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3])
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
	sceneGroup = self.view

	-- Code here runs when the scene is first created but has not yet appeared on screen
    local background = display.newRect(sceneGroup, 0, 0, 800, 1280)
    background:setFillColor(BACKGROUND_COLOR[1], BACKGROUND_COLOR[2], BACKGROUND_COLOR[3])
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    createButtonWithBorder(sceneGroup, "<- Back", 16, 0, 8, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, nextScene)
    createButtonWithBorder(sceneGroup, "Switch Team", 16, 0, 40, 2, TEXT_COLOR, TEXT_COLOR, TRANSPARENT, switchTeam)

    displayHeader()
    displayQtrBreakdownHeader()

    for i = 1, #qtrScores do
        displayQtrBreakdown(qtrScores[i], i)
    end
    
    if(showingUserTeamStats) then
        for i = 1, #team.players do
            showPlayerStats(team.players[i], i)
        end
    else
        for i = 1, #opponent.players do
            showPlayerStats(opponent.players[i], i)
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
