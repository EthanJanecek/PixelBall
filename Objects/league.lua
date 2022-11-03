local TeamLib = require("Objects.team")
StatsLib = require("Objects.stats")
local json = require( "json" )

local league = {}

local leagueAvgFinishing = 68
local leagueAvgClose = 43
local leagueAvgMidRange = 40
local leagueAvg3 = 37

local skillScaling = 3
local playerPercentages = {35, 60, 80, 92, 100}
local heightDiffMin = 5
local heightDiffMax = 15

local maxLoops = 200

local staminaRunningUsage = -.2
local shotStaminaUsage = -.4
local staminaStandingRegen = -staminaRunningUsage / 4
local staminaBenchRegen = -staminaRunningUsage

local numDefensiveStrategies = 5

local turnoverAverage = 13
local blockedAverage = 5
local maxBlockedProb = 20

function league:createLeague()
    self.__index = self

    return setmetatable({
        teams=createTeams(),
        userTeam="",
        weekNum=1,
        numGames=games,
        numDays=numDays,
        difficulty=difficulty,
        minutesInQtr=minutesInQtr,
        schedule={},
        playoffs={},
        playoffTeams={},
        regularSeason=true,
        playoffsActive=false
    }, self)
end

function league:createFromSave()
    local path = getSaveDirectory()
    local file = io.open(path, "r")
    
	local contents = file:read("*a")
	local t = json.decode(contents)

	userTeam = t.userTeam
    games = t.numGames
    numDays = t.numDays
    difficulty = t.difficulty
    minutesInQtr = t.minutesInQtr
    regularSeason = t.regularSeason
    playoffs = t.playoffsActive

    self.__index = self

    return setmetatable(t, self)
end

function createTeams()
    local teams = {}

    -- Eastern Conference
    -- Atlantic Division
    table.insert(teams, TeamLib:create("76ers", "PHI", "images/logos/76ers.png", "East", "Atlantic", "blue", "data/philadelphia-76ers.csv"))
    table.insert(teams, TeamLib:create("Nets", "BKN", "images/logos/nets.png", "East", "Atlantic", "black", "data/brooklyn-nets.csv"))
    table.insert(teams, TeamLib:create("Celtics", "BOS", "images/logos/celtics.png", "East", "Atlantic", "green", "data/boston-celtics.csv"))
    table.insert(teams, TeamLib:create("Raptors", "TOR", "images/logos/raptors.png", "East", "Atlantic", "red", "data/toronto-raptors.csv"))
    table.insert(teams, TeamLib:create("Knicks", "NYK", "images/logos/knicks.png", "East", "Atlantic", "blue", "data/new-york-knicks.csv"))

    -- Central Division
    table.insert(teams, TeamLib:create("Bucks", "MIL", "images/logos/bucks.png", "East", "Central", "green", "data/milwaukee-bucks.csv"))
    table.insert(teams, TeamLib:create("Pacers", "IND", "images/logos/pacers.png", "East", "Central", "yellow", "data/indiana-pacers.csv"))
    table.insert(teams, TeamLib:create("Pistons", "DET", "images/logos/pistons.png", "East", "Central", "blue", "data/detroit-pistons.csv"))
    table.insert(teams, TeamLib:create("Bulls", "CHI", "images/logos/bulls.png", "East", "Central", "red", "data/chicago-bulls.csv"))
    table.insert(teams, TeamLib:create("Cavaliers", "CLE", "images/logos/cavaliers.png", "East", "Central", "black", "data/cleveland-cavaliers.csv"))

    -- Southeast Division
    table.insert(teams, TeamLib:create("Heat", "MIA", "images/logos/heat.png", "East", "Southeast", "red", "data/miami-heat.csv"))
    table.insert(teams, TeamLib:create("Magic", "ORL", "images/logos/magic.png", "East", "Southeast", "blue", "data/orlando-magic.csv"))
    table.insert(teams, TeamLib:create("Hawks", "ATL", "images/logos/hawks.png", "East", "Southeast", "red", "data/atlanta-hawks.csv"))
    table.insert(teams, TeamLib:create("Wizards", "WAS", "images/logos/wizards.png", "East", "Southeast", "blue", "data/washington-wizards.csv"))
    table.insert(teams, TeamLib:create("Hornets", "CHA", "images/logos/hornets.png", "East", "Southeast", "blue", "data/charlotte-hornets.csv"))

    -- Western Conference
    -- Pacific Division
    table.insert(teams, TeamLib:create("Lakers", "LAL", "images/logos/lakers.png", "West", "Pacific", "yellow", "data/los-angeles-lakers.csv"))
    table.insert(teams, TeamLib:create("Clippers", "LAC", "images/logos/clippers.png", "West", "Pacific", "blue", "data/los-angeles-clippers.csv"))
    table.insert(teams, TeamLib:create("Suns", "PHX", "images/logos/suns.png", "West", "Pacific", "purple", "data/phoenix-suns.csv"))
    table.insert(teams, TeamLib:create("Warriors", "GSW", "images/logos/warriors.png", "West", "Pacific", "blue", "data/golden-state-warriors.csv"))
    table.insert(teams, TeamLib:create("Kings", "SAC", "images/logos/kings.png", "West", "Pacific", "purple", "data/sacramento-kings.csv"))

    -- Northwest Division
    table.insert(teams, TeamLib:create("Nuggets", "DEN", "images/logos/nuggets.png", "West", "Northwest", "blue", "data/denver-nuggets.csv"))
    table.insert(teams, TeamLib:create("Jazz", "UTA", "images/logos/jazz.png", "West", "Northwest", "orange", "data/utah-jazz.csv"))
    table.insert(teams, TeamLib:create("Trail Blazers", "POR", "images/logos/trail blazers.png", "West", "Northwest", "black", "data/portland-trail-blazers.csv"))
    table.insert(teams, TeamLib:create("Thunder", "OKC", "images/logos/thunder.png", "West", "Northwest", "blue", "data/oklahoma-city-thunder.csv"))
    table.insert(teams, TeamLib:create("Timberwolves", "MIN", "images/logos/timberwolves.png", "West", "Northwest", "blue", "data/minnesota-timberwolves.csv"))

    -- Southwest Division
    table.insert(teams, TeamLib:create("Rockets", "HOU", "images/logos/rockets.png", "West", "Southwest", "red", "data/houston-rockets.csv"))
    table.insert(teams, TeamLib:create("Spurs", "SAS", "images/logos/spurs.png", "West", "Southwest", "black", "data/san-antonio-spurs.csv"))
    table.insert(teams, TeamLib:create("Pelicans", "NOP", "images/logos/pelicans.png", "West", "Southwest", "red", "data/new-orleans-pelicans.csv"))
    table.insert(teams, TeamLib:create("Mavericks", "DAL", "images/logos/mavericks.png", "West", "Southwest", "blue", "data/dallas-mavericks.csv"))
    table.insert(teams, TeamLib:create("Grizzlies", "MEM", "images/logos/grizzlies.png", "West", "Southwest", "cyan", "data/memphis-grizzlies.csv"))

    return teams
end

function checkIfTeamPlays(weeklySchedule, team)
    if(weeklySchedule) then
        for i = 1, #weeklySchedule do
            if(weeklySchedule[i].home == team or weeklySchedule[i].away == team) then
                return true
            end
        end
    end

    return false
end

function league:findGameInfo(weeklySchedule, team)
    if(weeklySchedule) then
        for i = 1, #weeklySchedule do
            if(weeklySchedule[i].home == team or weeklySchedule[i].away == team) then
                return weeklySchedule[i]
            end
        end
    end

    return nil
end

function league:createSchedule()
    self.schedule = {}

    for i = 1, numDays do
        local weeklySchedule = {}
        table.insert(self.schedule, weeklySchedule)
    end

    for i = 1, 30 do
        local team1 = self.teams[i]

        for j = i + 1, 30 do
            local team2 = self.teams[j]
            local numGames = 0

            if(games == 29) then
                numGames = 1
            elseif(games == 58) then
                numGames = 2
            else
                numGames = 2
                if(team1.conf == team2.conf) then
                    numGames = 3
                end
            end

            for k = 1, numGames do
                local weekNum = math.random(numDays)
                local loops = 0

                while(checkIfTeamPlays(self.schedule[weekNum], team1.name) or checkIfTeamPlays(self.schedule[weekNum], team2.name)) do
                    weekNum = math.random(numDays)
                    loops = loops + 1

                    if(loops > maxLoops) then
                        -- Don't want to get stuck in infinite loop
                        self.createSchedule()
                        break
                    end
                end
                
                if(k % 2 == 0) then
                    table.insert(self.schedule[weekNum], {away=team1.name, home=team2.name, score={}})
                else
                    table.insert(self.schedule[weekNum], {away=team2.name, home=team1.name, score={}})
                end
            end
        end
    end
end

function league:findTeam(name)
    for i = 1, 30 do
        local team = self.teams[i]

        if(team.name == name) then
            return team
        end
    end

    return {}
end

function league:findPlayoffTeam(name)
    for i = 1, #self.playoffTeams.east do
        local team = self.playoffTeams.east[i]

        if(team.team == name) then
            return team
        end
    end

    for i = 1, #self.playoffTeams.west do
        local team = self.playoffTeams.west[i]

        if(team.team == name) then
            return team
        end
    end

    return {}
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

function league:getEastTeams()
    local eastTeams = {}
    local num = 1

    for i = 1, #self.teams do
        local team = self.teams[i]
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

function league:getWestTeams()
    local westTeams = {}
    local num = 1

    for i = 1, #self.teams do
        local team = self.teams[i]
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

function league:resetPlayoffWins()
    for i = 1, #self.playoffTeams.east do
        self.playoffTeams.east[i].wins = 0
        self.playoffTeams.east[i].losses = 0
    end

    for i = 1, #self.playoffTeams.west do
        self.playoffTeams.west[i].wins = 0
        self.playoffTeams.west[i].losses = 0
    end
end

function league:startPlayoffs()
    self.regularSeason = false
    regularSeason = false
    self.weekNum = 1

    for i = 1, 30 do
        local weeklySchedule = {}
        table.insert(self.playoffs, weeklySchedule)
    end

    local eastTeams = self:getEastTeams()
    local westTeams = self:getWestTeams()
    self.playoffTeams = {
        east = {},
        west = {}
    }

    for i = 1, 6 do
        table.insert(self.playoffTeams.east, {
            team = eastTeams[i].name,
            wins = 0,
            losses = 0,
            seed = i
        })
        table.insert(self.playoffTeams.west, {
            team = westTeams[i].name,
            wins = 0,
            losses = 0,
            seed = i
        })
    end

    table.insert(self.playoffs[1], {away=eastTeams[8].name, home=eastTeams[7].name, score={}})
    table.insert(self.playoffs[1], {away=eastTeams[10].name, home=eastTeams[9].name, score={}})

    table.insert(self.playoffs[1], {away=westTeams[8].name, home=westTeams[7].name, score={}})
    table.insert(self.playoffs[1], {away=westTeams[10].name, home=westTeams[9].name, score={}})
end

function league:playinRoundTwo()
    local east1Game = self.playoffs[1][1]
    local winnerEast1 = east1Game.home
    local loserEast1 = east1Game.away

    if(east1Game.score.away > east1Game.score.home) then
        winnerEast1 = east1Game.away
        loserEast1 = east1Game.home
    end

    local east2Game = self.playoffs[1][2]
    local winnerEast2 = east2Game.home

    if(east2Game.score.away > east2Game.score.home) then
        winnerEast2 = east2Game.away
    end

    local west1Game = self.playoffs[1][3]
    local winnerWest1 = west1Game.home
    local loserWest1 = west1Game.away

    if(west1Game.score.away > west1Game.score.home) then
        winnerWest1 = west1Game.away
        loserWest1 = west1Game.home
    end

    local west2Game = self.playoffs[1][4]
    local winnerWest2 = west2Game.home

    if(west2Game.score.away > west2Game.score.home) then
        winnerWest2 = west2Game.away
    end

    table.insert(self.playoffTeams.east, {
        team = winnerEast1,
        wins = 0,
        losses = 0,
        seed = 7
    })
    table.insert(self.playoffTeams.west, {
        team = winnerWest1,
        wins = 0,
        losses = 0,
        seed = 7
    })

    table.insert(self.playoffs[2], {away=winnerEast2, home=loserEast1, score={}})
    table.insert(self.playoffs[2], {away=winnerWest2, home=loserWest1, score={}})
end

function league:firstRoundSchedule()
    for i = 1, 4 do
        local team1 = self.playoffTeams.east[i].team
        local team2 = self.playoffTeams.east[9 - i].team

        table.insert(self.playoffs[3], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[4], {away=team2, home=team1, score={}})

        table.insert(self.playoffs[5], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[6], {away=team1, home=team2, score={}})

        table.insert(self.playoffs[7], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[8], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[9], {away=team2, home=team1, score={}})
    end

    for i = 1, 4 do
        local team1 = self.playoffTeams.west[i].team
        local team2 = self.playoffTeams.west[9 - i].team

        table.insert(self.playoffs[3], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[4], {away=team2, home=team1, score={}})

        table.insert(self.playoffs[5], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[6], {away=team1, home=team2, score={}})

        table.insert(self.playoffs[7], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[8], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[9], {away=team2, home=team1, score={}})
    end
end

function league:firstRound()
    self.playoffsActive = true
    playoffs = true
    
    local eastGame = self.playoffs[2][1]
    local winnerEast = eastGame.home

    if(eastGame.score.away > eastGame.score.home) then
        winnerEast = eastGame.away
    end

    local westGame = self.playoffs[2][2]
    local winnerWest = westGame.home

    if(westGame.score.away > westGame.score.home) then
        winnerWest = westGame.away
    end

    table.insert(self.playoffTeams.east, {
        team = winnerEast,
        wins = 0,
        losses = 0,
        seed = 8
    })
    table.insert(self.playoffTeams.west, {
        team = winnerWest,
        wins = 0,
        losses = 0,
        seed = 8
    })

    self:resetPlayoffWins()
    self:firstRoundSchedule()
end

function league:filterOutLosers()
    local teamsToRemoveEast = {}
    for i = 1, #self.playoffTeams.east do
        if self.playoffTeams.east[i].wins < 4 then
            table.insert(teamsToRemoveEast, self.playoffTeams.east[i])
        end
    end

    local teamsToRemoveWest = {}
    for i = 1, #self.playoffTeams.west do
        if self.playoffTeams.west[i].wins < 4 then
            table.insert(teamsToRemoveWest, self.playoffTeams.west[i])
        end
    end

    for i = 1, #teamsToRemoveEast do
        local index = indexOf(self.playoffTeams.east, teamsToRemoveEast[i])
        table.remove(self.playoffTeams.east, index)
    end

    for i = 1, #teamsToRemoveWest do
        local index = indexOf(self.playoffTeams.west, teamsToRemoveWest[i])
        table.remove(self.playoffTeams.west, index)
    end
end

function league:secondRoundSchedule()
    local startGameIndex = 10

    for i = 1, 2 do
        local team1 = self.playoffTeams.east[i].team
        local team2 = self.playoffTeams.east[5 - i].team

        table.insert(self.playoffs[startGameIndex], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[startGameIndex + 1], {away=team2, home=team1, score={}})

        table.insert(self.playoffs[startGameIndex + 2], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[startGameIndex + 3], {away=team1, home=team2, score={}})

        table.insert(self.playoffs[startGameIndex + 4], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[startGameIndex + 5], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[startGameIndex + 6], {away=team2, home=team1, score={}})
    end

    for i = 1, 2 do
        local team1 = self.playoffTeams.west[i].team
        local team2 = self.playoffTeams.west[5 - i].team

        table.insert(self.playoffs[startGameIndex], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[startGameIndex + 1], {away=team2, home=team1, score={}})

        table.insert(self.playoffs[startGameIndex + 2], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[startGameIndex + 3], {away=team1, home=team2, score={}})

        table.insert(self.playoffs[startGameIndex + 4], {away=team2, home=team1, score={}})
        table.insert(self.playoffs[startGameIndex + 5], {away=team1, home=team2, score={}})
        table.insert(self.playoffs[startGameIndex + 6], {away=team2, home=team1, score={}})
    end
end

function league:secondRound()
    self:filterOutLosers()
    self:resetPlayoffWins()
    self:secondRoundSchedule()
end

function league:conferenceChampionshipSchedule()
    local startGameIndex = 17

    local team1 = self.playoffTeams.east[1].team
    local team2 = self.playoffTeams.east[2].team

    table.insert(self.playoffs[startGameIndex], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 1], {away=team2, home=team1, score={}})

    table.insert(self.playoffs[startGameIndex + 2], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 3], {away=team1, home=team2, score={}})

    table.insert(self.playoffs[startGameIndex + 4], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 5], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 6], {away=team2, home=team1, score={}})

    team1 = self.playoffTeams.west[1].team
    team2 = self.playoffTeams.west[2].team

    table.insert(self.playoffs[startGameIndex], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 1], {away=team2, home=team1, score={}})

    table.insert(self.playoffs[startGameIndex + 2], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 3], {away=team1, home=team2, score={}})

    table.insert(self.playoffs[startGameIndex + 4], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 5], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 6], {away=team2, home=team1, score={}})
end

function league:conferenceChampionship()
    self:filterOutLosers()
    self:resetPlayoffWins()
    self:conferenceChampionshipSchedule()
end

function league:finalsSchedule()
    local startGameIndex = 24

    local team1 = self.playoffTeams.east[1].team
    local team2 = self.playoffTeams.west[1].team

    if(self:findPlayoffTeam(team1).wins < self:findPlayoffTeam(team2).wins) then
        team1 = self.playoffTeams.west[1].team
        team2 = self.playoffTeams.east[1].team
    end

    table.insert(self.playoffs[startGameIndex], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 1], {away=team2, home=team1, score={}})

    table.insert(self.playoffs[startGameIndex + 2], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 3], {away=team1, home=team2, score={}})

    table.insert(self.playoffs[startGameIndex + 4], {away=team2, home=team1, score={}})
    table.insert(self.playoffs[startGameIndex + 5], {away=team1, home=team2, score={}})
    table.insert(self.playoffs[startGameIndex + 6], {away=team2, home=team1, score={}})
end

function league:finals()
    self:filterOutLosers()
    self:resetPlayoffWins()
    self:finalsSchedule()
end

local function calculatePlayerExp(player)
    local stats = player.gameStats

    local shotPercent = 0
    if((stats.twoPA + stats.threePA) > 0) then
        shotPercent = (stats.twoPM + stats.threePM) / (stats.twoPA + stats.threePA)
    end
    
    local expRaw = (stats.points * shotPercent * 2.5) + (stats.steals + stats.blocks - stats.turnovers) * 5
    local factor = math.pow(player.potential / 10.0, player.years)
    local exp = factor * expRaw

    -- Exp is calculated for numGamesSetting = 3
    if(numGamesSetting == 1) then
        exp = exp * 2.5
    elseif(numGamesSetting == 2) then
        exp = exp * 1.25
    end

    -- Exp is calculated for minutesInQtrSetting = 3
    if(minutesInQtrSetting == 1) then
        exp = exp * 3
    elseif(minutesInQtrSetting == 2) then
        exp = exp * 1.5
    end

    if(exp > 50) then
        exp = 50
    elseif(exp < 0) then
        exp = 0
    end

    return math.round(exp)
end

local function assignRandomLevel(player)
    local statValue = 10
    local stat = -1

    while(statValue == 10) do
        stat = math.random(1, 11)

        if(stat == 1) then
            statValue = player.finishing
        elseif(stat == 2) then
            statValue = player.closeShot
        elseif(stat == 3) then
            statValue = player.midRange
        elseif(stat == 4) then
            statValue = player.three
        elseif(stat == 5) then
            statValue = player.dribbling
        elseif(stat == 6) then
            statValue = player.passing
        elseif(stat == 7) then
            statValue = player.passDefending
        elseif(stat == 8) then
            statValue = player.stealing
        elseif(stat == 9) then
            statValue = player.contestingInterior
        elseif(stat == 10) then
            statValue = player.contestingExterior
        else
            statValue = player.blocking
        end
    end

    if(stat == 1) then
        player.finishing = player.finishing + 1
    elseif(stat == 2) then
        player.closeShot = player.closeShot + 1
    elseif(stat == 3) then
        player.midRange = player.midRange + 1
    elseif(stat == 4) then
        player.three = player.three + 1
    elseif(stat == 5) then
        player.dribbling = player.dribbling + 1
    elseif(stat == 6) then
        player.passing = player.passing + 1
    elseif(stat == 7) then
        player.passDefending = player.passDefending + 1
    elseif(stat == 8) then
        player.stealing = player.stealing + 1
    elseif(stat == 9) then
        player.contestingInterior = player.contestingInterior + 1
    elseif(stat == 10) then
        player.contestingExterior = player.contestingExterior + 1
    else
        player.blocking = player.blocking + 1
    end

    player.levels = player.levels - 1
end

function league:giveExp(teamName)
    local team = self:findTeam(teamName)

    for i = 1, #team.players do
        local player = team.players[i]

        if(player:calculateOverall() < 10 and player:calculateOverall() < player.potential) then
            local exp = calculatePlayerExp(player)
            player.exp = player.exp + exp

            if(player.exp > 500) then
                player.exp = player.exp - 500
                player.levels = player.levels + 1

                if(teamName ~= userTeam) then
                    assignRandomLevel(player)
                end
            end
        end
    end
end

function league:nextWeek()
    local allGames = nil
    if(regularSeason) then
        allGames = self.schedule[self.weekNum]
    else
        allGames = self.playoffs[self.weekNum]
    end

    for i = 1, #allGames do
        local game = allGames[i]

        if(playoffs) then
            local away = self:findPlayoffTeam(game.away)
            local home = self:findPlayoffTeam(game.home)

            if((away.wins < 4 and home.wins < 4) and (game.away ~= userTeam and game.home ~= userTeam)) then
                print(game.away .. " vs. " .. game.home)

                local score = simulateGame(self:findTeam(game.away), self:findTeam(game.home))
                game.score = score

                if(game.score.away >= game.score.home) then
                    away.wins = away.wins + 1
                else
                    home.wins = home.wins + 1
                end
            end
        else
            if(game.away ~= userTeam and game.home ~= userTeam) then
                local score = simulateGame(self:findTeam(game.away), self:findTeam(game.home))
                game.score = score
            end

            self:giveExp(game.away)
            self:giveExp(game.home)
        end
    end

    self.weekNum = self.weekNum + 1
end

local function changeStamina(player, diff)
    player.stamina = player.stamina + diff

    if(player.stamina > player.maxStamina) then
        player.stamina = player.maxStamina
    elseif(player.stamina < 1) then
        player.stamina = 1
    end
end

local function sumProps(player)
    return player.closeShot + player.midRange + player.three + player.finishing + player.contestingInterior + player.contestingExterior + player.height + player.dribbling
                + player.blocking + player.stealing + player.speed
end

local function indexOf(table, value)
    for i = 1, #table do
        if(table[i] == value) then
            return i
        end
    end

    return -1
end

local function staminaPercent(player)
    return player.stamina / player.maxStamina
end

local function findBestAvailableBenchPlayer(team)
    local len = #team.players

    for i = 6, len do
        if(team.players[i].starter == true and staminaPercent(team.players[i]) > .8) then
            return i
        end
    end

    local teamBench = {unpack(team.players, 6, len)}
    table.sort(teamBench, function (a, b) 
        return sumProps(a) > sumProps(b)
    end)

    for i = 1, #teamBench do
        if(staminaPercent(teamBench[i]) > .8) then
            return indexOf(team.players, teamBench[i])
        end
    end

    return 6
end

local function isStarterAvailable(team)
    for i = 6, #team.players do
        if(team.players[i].starter == true and staminaPercent(team.players[i]) > .8) then
            return true
        end
    end

    return false
end

local function setStarters(team)
    for i = 1, 5 do
        if(not team.players[i].starter) then
            local j = findBestAvailableBenchPlayer(team)
            local tmp = team.players[i]
            team.players[i] = team.players[j]
            team.players[j] = tmp
        end
    end
end

local function resetStaminaAndStats(team)
    for i = 1, #team.players do
        team.players[i].stamina = team.players[i].maxStamina

        local stats = team.players[i].gameStats
        addStats(team.players[i].yearStats, stats)
        addStats(team.players[i].careerStats, stats)
        team.players[i].gameStats = StatsLib:createStats()
    end
end

function league:resetTeams()
    for i = 1, 30 do
        resetStaminaAndStats(self.teams[i])
        setStarters(self.teams[i])
    end
end

local function subPlayers(team)
    for i = 1, 5 do
        if(staminaPercent(team.players[i]) < .5 or (not team.players[i].starter and isStarterAvailable(team))) then
            local j = findBestAvailableBenchPlayer(team)
            local tmp = team.players[i]
            team.players[i] = team.players[j]
            team.players[j] = tmp
        end
    end
end

function simulateGame(away, home)
    local index = math.random(1, 2)
    local maxTime = 4 * minutesInQtr * 60
    local time = 0
    local score = {away = 0, home = 0}

    while time <= maxTime do
        if index % 2 == 0 then
            local result = simulatePossession(home, away, math.random(numDefensiveStrategies))
            score.home = score.home + result.points
            time = time + result.time
        else
            local result = simulatePossession(away, home, math.random(numDefensiveStrategies))
            score.away = score.away + result.points
            time = time + result.time
        end

        index = index + 1
    end

    -- Don't allow ties
    while(score.home == score.away) do
        -- Simulate 5 possessions each
        for i = 1, 5 do
            local result = simulatePossession(home, away, math.random(numDefensiveStrategies))
            score.home = score.home + result.points
            time = time + result.time

            result = simulatePossession(away, home, math.random(numDefensiveStrategies))
            score.away = score.away + result.points
            time = time + result.time
        end
    end
    
    if(score.home > score.away) then
        home.wins = home.wins + 1
        away.losses = away.losses + 1
    else
        away.wins = away.wins + 1
        home.losses = home.losses + 1
    end

    return score
end

local function changeTeamStamina(offense, defense, player, defender)
    changeStamina(player, shotStaminaUsage + staminaRunningUsage)
    changeStamina(defender, staminaRunningUsage)
    
    for i = 1, #offense.players do
        if(offense.players[i] ~= player) then
            if(i > 5) then
                changeStamina(offense.players[i], staminaBenchRegen)
            else
                changeStamina(offense.players[i], staminaStandingRegen)
            end
        end
    end

    for i = 1, #defense.players do
        if(defense.players[i] ~= defender) then
            if(i > 5) then
                changeStamina(defense.players[i], staminaBenchRegen)
            else
                changeStamina(defense.players[i], staminaStandingRegen)
            end
        end
    end
end

local function turnover(player, defender)
    local turnoverProb = turnoverAverage + ((defender.stealing - player.dribbling) * 6)

    local num = math.random(100)

    if(num <= turnoverProb) then
        return true
    else
        return false
    end
end

local function blocked(player, defender)
    local heightDiff = defender.height - player.height + 10 -- Will be from 0-20
    if(heightDiff < heightDiffMin) then
        heightDiff = heightDiffMin
    elseif(heightDiff > heightDiffMax) then
        heightDiff = heightDiffMax
    end

    heightDiff = heightDiff / 10.0

    local blockedProb = blockedAverage + ((defender.blocking) * heightDiff * .85)
    if(blockedProb > maxBlockedProb) then
        blockedProb = maxBlockedProb
    end

    local num = math.random(100)

    if(num <= blockedProb) then
        return true
    else
        return false
    end
end

local function adjustPlusMinus(offense, defense, points)
    for i = 1, 5 do
        offense.players[i].gameStats.plusMinus = offense.players[i].gameStats.plusMinus + points
        defense.players[i].gameStats.plusMinus = defense.players[i].gameStats.plusMinus - points
    end
end

function simulatePossession(offense, defense, defenseStrategy)
    local defensiveStrategy = defenseStrategy or 1
    subPlayers(offense)

    local teamStarters = {unpack(offense.players, 1, 5)}
    table.sort(teamStarters, function (a, b) 
        return (a.closeShot + a.midRange + a.three + a.finishing) > (b.closeShot + b.midRange + b.three + b.finishing)
    end)

    local opponentStarters = {unpack(defense.players, 1, 5)}

    if(defensiveStrategy == 1) then -- Overall defending skill
        table.sort(opponentStarters, function (a, b)
            return (a.contestingInterior + a.contestingExterior) > (b.contestingInterior + b.contestingExterior)
        end)
    elseif(defensiveStrategy == 2) then -- Speed
        local teamStarters2 = {unpack(offense.players, 1, 5)}
        table.sort(teamStarters2, function (a, b) 
            return a.speed > b.speed
        end)

        local opponentStarters2 = {unpack(defense.players, 1, 5)}
        table.sort(opponentStarters2, function (a, b)
            return a.speed > b.speed
        end)

        for i = 1, 5 do
            local index = indexOf(teamStarters, teamStarters2[i])
            opponentStarters[index] = opponentStarters2[i]
        end
    elseif(defensiveStrategy == 3) then -- Interior Defending
        local teamStarters2 = {unpack(offense.players, 1, 5)}
        table.sort(teamStarters2, function (a, b) 
            return (a.finishing + a.closeShot) > (b.closeShot + b.finishing)
        end)

        local opponentStarters2 = {unpack(defense.players, 1, 5)}
        table.sort(opponentStarters2, function (a, b)
            return a.contestingInterior > b.contestingInterior
        end)

        for i = 1, 5 do
            local index = indexOf(teamStarters, teamStarters2[i])
            opponentStarters[index] = opponentStarters2[i]
        end
    elseif(defensiveStrategy == 4) then -- Exterior Defending
        local teamStarters2 = {unpack(offense.players, 1, 5)}
        table.sort(teamStarters2, function (a, b) 
            return (a.midRange + a.three) > (b.midRange + b.three)
        end)

        local opponentStarters2 = {unpack(defense.players, 1, 5)}
        table.sort(opponentStarters2, function (a, b)
            return a.contestingExterior > b.contestingExterior
        end)

        for i = 1, 5 do
            local index = indexOf(teamStarters, teamStarters2[i])
            opponentStarters[index] = opponentStarters2[i]
        end
    elseif(defensiveStrategy == 5) then -- Height
        local teamStarters2 = {unpack(offense.players, 1, 5)}
        table.sort(teamStarters2, function (a, b) 
            return a.height > b.height
        end)

        local opponentStarters2 = {unpack(defense.players, 1, 5)}
        table.sort(opponentStarters2, function (a, b)
            return a.height > b.height
        end)

        for i = 1, 5 do
            local index = indexOf(teamStarters, teamStarters2[i])
            opponentStarters[index] = opponentStarters2[i]
        end
    end

    local playerNum = math.random(1, 100)
    local player = teamStarters[1]
    local defender = opponentStarters[1]

    for i = 1, 5 do
        if(playerNum <= playerPercentages[i]) then
            player = teamStarters[i]
            defender = opponentStarters[i]
            break
        end
    end

    local max = player.finishing + player.closeShot + player.midRange + player.three
    local shotType = math.random(max)
    local time = math.random(6, 24)
    local points = 0
    local shotPoints = 0

    local heightDiff = player.height - defender.height + 10 -- Will be from 0-20
    if(heightDiff < heightDiffMin) then
        heightDiff = heightDiffMin
    elseif(heightDiff > heightDiffMax) then
        heightDiff = heightDiffMax
    end

    if(shotType <= player.finishing) then
        shotPoints = 2
        points = calculatePoints(player.finishing * staminaPercent(player), defender.contestingInterior * staminaPercent(defender), heightDiff, leagueAvgFinishing, 2, player, defender)
    elseif(shotType <= (player.finishing + player.closeShot)) then
        shotPoints = 2
        points = calculatePoints(player.closeShot * staminaPercent(player), defender.contestingInterior * staminaPercent(defender), heightDiff, leagueAvgClose, 2, player, defender)
    elseif(shotType <= (player.finishing + player.closeShot + player.midRange)) then
        shotPoints = 2
        points = calculatePoints(player.midRange * staminaPercent(player), defender.contestingExterior * staminaPercent(defender), heightDiff, leagueAvgMidRange, 2, player, defender)
    else
        shotPoints = 3
        points = calculatePoints(player.three * staminaPercent(player), defender.contestingExterior * staminaPercent(defender), heightDiff, leagueAvg3, 3, player, defender)
    end

    local message = "Defended"
    if(turnover(player, defender)) then
        points = 0
        player.gameStats.turnovers = player.gameStats.turnovers + 1
        defender.gameStats.steals = defender.gameStats.steals + 1
        message = "Stolen"

        time = time / 2
        if(time < 6) then
            time = 6
        end
    elseif(blocked(player, defender)) then
        points = 0
        defender.gameStats.blocks = defender.gameStats.blocks + 1
        defender.gameStats.shotsAgainst = defender.gameStats.shotsAgainst + 1
        message = "Blocked"
    end

    changeTeamStamina(offense, defense, player, defender)

    if shotPoints == 2 then
        defender.gameStats.shotsAgainst = defender.gameStats.shotsAgainst + 1
        defender.gameStats.pointsAgainst = defender.gameStats.pointsAgainst + points
        player.gameStats.twoPA = player.gameStats.twoPA + 1

        if points ~= 0 then
            adjustPlusMinus(offense, defense, 2)
            player.gameStats.points = player.gameStats.points + 2
            player.gameStats.twoPM = player.gameStats.twoPM + 1
        end
    else
        defender.gameStats.shotsAgainst = defender.gameStats.shotsAgainst + 1
        defender.gameStats.pointsAgainst = defender.gameStats.pointsAgainst + points
        player.gameStats.threePA = player.gameStats.threePA + 1

        if points ~= 0 then
            adjustPlusMinus(offense, defense, 3)
            player.gameStats.points = player.gameStats.points + 3
            player.gameStats.threePM = player.gameStats.threePM + 1
        end
    end
    
    return {points=points, time=time, player=player, defender=defender, message=message}
end

local function wideOpenShot(player, defender)
    local speedByProb = (player.speed - defender.speed) * 5
    local crossUpProb = (player.dribbling - defender.quickness) * 5

    local num = math.random(100)

    if(num <= speedByProb or num <= crossUpProb) then
        return true
    else
        return false
    end
end

function calculatePoints(shooterSkill, defenderSkill, heightDiff, leagueAvg, maxPoints, player, defender)
    local shotPercent = math.random(100)
    local heightFactor = (shooterSkill - defenderSkill >= 0) and (heightDiff / 10) or ((heightDiff + 10) / 10)
    local scaling = (shooterSkill - defenderSkill) * skillScaling * heightFactor
    local wideOpen = wideOpenShot(player, defender)

    if(wideOpen) then
        local scaling = shooterSkill * skillScaling
    end

    local percentageMade = leagueAvg + scaling

    if(shotPercent <= percentageMade) then
        return maxPoints
    else
        return 0
    end
end

return league