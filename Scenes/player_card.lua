local composer = require( "composer" )
local scene = composer.newScene()

local sceneGroup = nil
local player = nil
local team = nil
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
local paddingY = display.contentHeight - (rowDist * 3) - fontSize
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local function nextScene()
    local options = {
        params = {
            team = team
        }
    }

    composer.gotoScene("Scenes.roster", options)
end

local function levelUp()
    local options = {
        params = {
            team = team,
            player = player
        }
    }

    composer.gotoScene("Scenes.level_up", options)
end

local function displayStatsHeader()
    local name = display.newText(sceneGroup, "Name", display.contentWidth * statPositions[1] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, "Pts", display.contentWidth * statPositions[2] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, "2PM", display.contentWidth * statPositions[3] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, "2PA", display.contentWidth * statPositions[4] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, "3PM", display.contentWidth * statPositions[5] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, "3PA", display.contentWidth * statPositions[6] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, "BLK", display.contentWidth * statPositions[7] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)

    local steals = display.newText(sceneGroup, "STL", display.contentWidth * statPositions[8] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    steals:setFillColor(.922, .910, .329)

    local turnovers = display.newText(sceneGroup, "TRV", display.contentWidth * statPositions[9] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(.922, .910, .329)

    local plusMinus = display.newText(sceneGroup, "+/-", display.contentWidth * statPositions[10] + paddingX, 
                    paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(.922, .910, .329)

    local dividerHorizontal = display.newRect(sceneGroup, display.contentCenterX, paddingY + 4, display.contentWidth * 1.5, 2)
    dividerHorizontal:setStrokeColor(.922, .910, .329)
    dividerHorizontal:setFillColor(.922, .910, .329)
end

local function displayStats(text, stats, row)
    local name = display.newText(sceneGroup, text, display.contentWidth * statPositions[1] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    name:setFillColor(.922, .910, .329)

    local pts = display.newText(sceneGroup, stats.points, display.contentWidth * statPositions[2] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    pts:setFillColor(.922, .910, .329)

    local twoPM = display.newText(sceneGroup, stats.twoPM, display.contentWidth * statPositions[3] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPM:setFillColor(.922, .910, .329)

    local twoPA = display.newText(sceneGroup, stats.twoPA, display.contentWidth * statPositions[4] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    twoPA:setFillColor(.922, .910, .329)

    local threePM = display.newText(sceneGroup, stats.threePM, display.contentWidth * statPositions[5] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePM:setFillColor(.922, .910, .329)

    local threePA = display.newText(sceneGroup, stats.threePA, display.contentWidth * statPositions[6] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    threePA:setFillColor(.922, .910, .329)

    local blocks = display.newText(sceneGroup, stats.blocks, display.contentWidth * statPositions[7] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    blocks:setFillColor(.922, .910, .329)

    local steals = display.newText(sceneGroup, stats.steals, display.contentWidth * statPositions[8] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    steals:setFillColor(.922, .910, .329)

    local turnovers = display.newText(sceneGroup, stats.turnovers, display.contentWidth * statPositions[9] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    turnovers:setFillColor(.922, .910, .329)

    local plusMinus = display.newText(sceneGroup, stats.plusMinus, display.contentWidth * statPositions[10] + paddingX, 
                    row * rowDist + paddingY, native.systemFont, fontSize)
    plusMinus:setFillColor(.922, .910, .329)
end

local function displayString(text, x, y)
    local label = display.newText(sceneGroup, text, x, y, native.systemFont, 16)
    label:setFillColor(.922, .910, .329)
end

local function displayAttributes()
    local y = 60
    displayString("Overall: " .. string.format("%.2f", calculateOverall(player)), 0, y)
    displayString("Potential: " .. player.potential, display.contentWidth * .33, y)
    displayString("Experience: " .. player.exp .. "/500", display.contentWidth * .67, y)
    displayString("Years in NBA: " .. player.years, display.contentWidth, y)
    
    y = y + 35
    displayString("Height: " .. player.height, 0, y)
    displayString("Speed: " .. player.speed, display.contentWidth * .33, y)
    displayString("Ball Speed: " .. player.ballSpeed, display.contentWidth * .67, y)
    displayString("Quickness: " .. player.quickness, display.contentWidth, y)

    y = y + 25
    displayString("Stamina: " .. player.maxStamina, display.contentWidth * .33, y)
    displayString("Strength: " .. player.strength, display.contentWidth * .67, y)

    y = y + 35
    displayString("Finishing: " .. player.finishing, 0, y)
    displayString("Close Shot: " .. player.closeShot, display.contentWidth * .33, y)
    displayString("Mid-Range: " .. player.midRange, display.contentWidth * .67, y)
    displayString("3-PT: " .. player.three, display.contentWidth, y)

    y = y + 25
    displayString("Dribbling: " .. player.dribbling, 0, y)
    displayString("Stealing: " .. player.stealing, display.contentWidth * .5, y)
    displayString("Blocking: " .. player.blocking, display.contentWidth, y)

    y = y + 25
    displayString("Interior Defending: " .. player.contestingInterior, display.contentWidth * .25, y)
    displayString("Exterior Defending: " .. player.contestingExterior, display.contentWidth * .75, y)
end

local function showPlayer()
    -- Number + Name
    local nameStr = "#" .. player.number .. " - " .. player.name
    local startersLabel = display.newText(sceneGroup, nameStr, display.contentCenterX, 20, native.systemFont, 24)
    startersLabel:setFillColor(.922, .910, .329)

    -- Attributes
    displayAttributes()

    --Stats
    displayStatsHeader()
    displayStats("Season", player.yearStats, 1)
    displayStats("Career", player.careerStats, 2)
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

    createButtonWithBorder(sceneGroup, "<- Back", 16, 8, 8, 2, BLACK, BLACK, TRANSPARENT, nextScene)
    
    if(player.levels > 0) then
        createButtonWithBorder(sceneGroup, "Level Up (" .. player.levels .. ")", 16, display.contentWidth - 8, 8, 2, 
                BLACK, BLACK, TRANSPARENT, levelUp)
    end

    showPlayer()
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
