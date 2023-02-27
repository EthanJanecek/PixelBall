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

local staminaRunningUsage = -.25
local shotStaminaUsage = -.45
local staminaStandingRegen = 0
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
        year=1,
        weekNum=1,
        numGames=games,
        numGamesSetting=numGamesSetting,
        numDays=numDays,
        difficulty=difficulty,
        minutesInQtr=minutesInQtr,
        schedule={},
        playoffs={},
        playoffTeams={},
        regularSeason=true,
        playoffsActive=false,
        freeAgents={}
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
    numGamesSetting = t.numGamesSetting
    difficulty = t.difficulty
    minutesInQtr = t.minutesInQtr
    regularSeason = t.regularSeason
    playoffs = t.playoffsActive

    self.__index = self

    return setmetatable(t, self)
end

local function setInitialTeamCapLevel(team)
    local capHit = calculateCap(team)

    if(capHit < SALARY_CAP_LEVEL_1) then
        team.cap = SALARY_CAP_LEVEL_1
    elseif(capHit < SALARY_CAP_LEVEL_2) then
        team.cap = SALARY_CAP_LEVEL_2
    elseif(capHit < SALARY_CAP_LEVEL_3) then
        team.cap = SALARY_CAP_LEVEL_3
    else
        team.cap = SALARY_CAP_MAX
    end
end

function createTeams()
    local teams = {}

    -- Eastern Conference
    -- Atlantic Division
    table.insert(teams, TeamLib:create("76ers", "PHI", "images/logos/76ers.png", "East", "Atlantic", "blue", "data/philadelphia-76ers.csv", MID_CITY))
    table.insert(teams, TeamLib:create("Nets", "BKN", "images/logos/nets.png", "East", "Atlantic", "black", "data/brooklyn-nets.csv", GREAT_CITY))
    table.insert(teams, TeamLib:create("Celtics", "BOS", "images/logos/celtics.png", "East", "Atlantic", "green", "data/boston-celtics.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Raptors", "TOR", "images/logos/raptors.png", "East", "Atlantic", "red", "data/toronto-raptors.csv", MID_CITY))
    table.insert(teams, TeamLib:create("Knicks", "NYK", "images/logos/knicks.png", "East", "Atlantic", "blue", "data/new-york-knicks.csv", GREAT_CITY))

    -- Central Division
    table.insert(teams, TeamLib:create("Bucks", "MIL", "images/logos/bucks.png", "East", "Central", "green", "data/milwaukee-bucks.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Pacers", "IND", "images/logos/pacers.png", "East", "Central", "yellow", "data/indiana-pacers.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Pistons", "DET", "images/logos/pistons.png", "East", "Central", "blue", "data/detroit-pistons.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Bulls", "CHI", "images/logos/bulls.png", "East", "Central", "red", "data/chicago-bulls.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Cavaliers", "CLE", "images/logos/cavaliers.png", "East", "Central", "black", "data/cleveland-cavaliers.csv", BAD_CITY))

    -- Southeast Division
    table.insert(teams, TeamLib:create("Heat", "MIA", "images/logos/heat.png", "East", "Southeast", "red", "data/miami-heat.csv", GREAT_CITY))
    table.insert(teams, TeamLib:create("Magic", "ORL", "images/logos/magic.png", "East", "Southeast", "blue", "data/orlando-magic.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Hawks", "ATL", "images/logos/hawks.png", "East", "Southeast", "red", "data/atlanta-hawks.csv", MID_CITY))
    table.insert(teams, TeamLib:create("Wizards", "WAS", "images/logos/wizards.png", "East", "Southeast", "blue", "data/washington-wizards.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Hornets", "CHA", "images/logos/hornets.png", "East", "Southeast", "blue", "data/charlotte-hornets.csv", BAD_CITY))

    -- Western Conference
    -- Pacific Division
    table.insert(teams, TeamLib:create("Lakers", "LAL", "images/logos/lakers.png", "West", "Pacific", "yellow", "data/los-angeles-lakers.csv", GREAT_CITY))
    table.insert(teams, TeamLib:create("Clippers", "LAC", "images/logos/clippers.png", "West", "Pacific", "blue", "data/los-angeles-clippers.csv", GREAT_CITY))
    table.insert(teams, TeamLib:create("Suns", "PHX", "images/logos/suns.png", "West", "Pacific", "purple", "data/phoenix-suns.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Warriors", "GSW", "images/logos/warriors.png", "West", "Pacific", "blue", "data/golden-state-warriors.csv", GREAT_CITY))
    table.insert(teams, TeamLib:create("Kings", "SAC", "images/logos/kings.png", "West", "Pacific", "purple", "data/sacramento-kings.csv", MID_CITY))

    -- Northwest Division
    table.insert(teams, TeamLib:create("Nuggets", "DEN", "images/logos/nuggets.png", "West", "Northwest", "blue", "data/denver-nuggets.csv", MID_CITY))
    table.insert(teams, TeamLib:create("Jazz", "UTA", "images/logos/jazz.png", "West", "Northwest", "orange", "data/utah-jazz.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Trail Blazers", "POR", "images/logos/trail blazers.png", "West", "Northwest", "black", "data/portland-trail-blazers.csv", MID_CITY))
    table.insert(teams, TeamLib:create("Thunder", "OKC", "images/logos/thunder.png", "West", "Northwest", "blue", "data/oklahoma-city-thunder.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Timberwolves", "MIN", "images/logos/timberwolves.png", "West", "Northwest", "blue", "data/minnesota-timberwolves.csv", MID_CITY))

    -- Southwest Division
    table.insert(teams, TeamLib:create("Rockets", "HOU", "images/logos/rockets.png", "West", "Southwest", "red", "data/houston-rockets.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Spurs", "SAS", "images/logos/spurs.png", "West", "Southwest", "black", "data/san-antonio-spurs.csv", BAD_CITY))
    table.insert(teams, TeamLib:create("Pelicans", "NOP", "images/logos/pelicans.png", "West", "Southwest", "red", "data/new-orleans-pelicans.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Mavericks", "DAL", "images/logos/mavericks.png", "West", "Southwest", "blue", "data/dallas-mavericks.csv", GOOD_CITY))
    table.insert(teams, TeamLib:create("Grizzlies", "MEM", "images/logos/grizzlies.png", "West", "Southwest", "cyan", "data/memphis-grizzlies.csv", MID_CITY))

    for i = 1, #teams do
        setInitialTeamCapLevel(teams[i])
    end

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
                        self:createSchedule()
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

function league:startDraftOrder()
    local eliminatedTeams = {}

    local eastTeams = self:getEastTeams()
    local westTeams = self:getWestTeams()

    for i = 11, 15 do
        table.insert(eliminatedTeams, eastTeams[i])
        table.insert(eliminatedTeams, westTeams[i])
    end

    table.sort(eliminatedTeams, function(team1, team2)
        return team1.wins < team2.wins
    end)

    for i = 1, #eliminatedTeams do
        eliminatedTeams[i].draftPosition = i
    end
end

function league:chooseRandomDraftOrder(team, positions)
    local num = math.random(1, #positions)
    team.draftPosition = positions[num]
    table.remove(positions, num)
    return positions
end

function league:startPlayoffs()
    self.regularSeason = false
    regularSeason = false
    self.weekNum = 1
    self.playoffs = {}

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

    self:startDraftOrder()
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
    local loserEast2 = east2Game.away

    if(east2Game.score.away > east2Game.score.home) then
        winnerEast2 = east2Game.away
        loserEast2 = east2Game.home
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
    local loserWest2 = west2Game.away

    if(west2Game.score.away > west2Game.score.home) then
        winnerWest2 = west2Game.away
        loserWest2 = west2Game.home
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

    local rand = math.random(2)
    if(rand == 1) then
        self:findTeam(loserEast2).draftPosition = 11
        self:findTeam(loserWest2).draftPosition = 12
    else
        self:findTeam(loserEast2).draftPosition = 12
        self:findTeam(loserWest2).draftPosition = 11
    end
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
    local loserEast = eastGame.away

    if(eastGame.score.away > eastGame.score.home) then
        winnerEast = eastGame.away
        loserEast = eastGame.home
    end

    local westGame = self.playoffs[2][2]
    local winnerWest = westGame.home
    local loserWest = westGame.away

    if(westGame.score.away > westGame.score.home) then
        winnerWest = westGame.away
        loserWest = westGame.home
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

    local rand = math.random(2)
    if(rand == 1) then
        self:findTeam(loserEast).draftPosition = 13
        self:findTeam(loserWest).draftPosition = 14
    else
        self:findTeam(loserEast).draftPosition = 14
        self:findTeam(loserWest).draftPosition = 13
    end

    self:resetPlayoffWins()
    self:firstRoundSchedule()
end

function league:filterOutLosers(startDraftPosition)
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

    local possiblePositions = {}
    local countTeamsEliminated = #teamsToRemoveEast + #teamsToRemoveWest
    for i = startDraftPosition, startDraftPosition + countTeamsEliminated - 1 do
        table.insert(possiblePositions, i)
    end

    for i = 1, #teamsToRemoveEast do
        local index = indexOf(self.playoffTeams.east, teamsToRemoveEast[i])
        local removedTeam = table.remove(self.playoffTeams.east, index)
        possiblePositions = self:chooseRandomDraftOrder(self:findTeam(removedTeam.team), possiblePositions)
    end

    for i = 1, #teamsToRemoveWest do
        local index = indexOf(self.playoffTeams.west, teamsToRemoveWest[i])
        local removedTeam = table.remove(self.playoffTeams.west, index)
        possiblePositions = self:chooseRandomDraftOrder(self:findTeam(removedTeam.team), possiblePositions)
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
    self:filterOutLosers(15)
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
    self:filterOutLosers(23)
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
    self:filterOutLosers(27)
    self:resetPlayoffWins()
    self:finalsSchedule()
end

local function calculatePlayerExp(player)
    local stats = player.stats[#player.stats]

    local shotPercent = 0
    if((stats.twoPA + stats.threePA) > 0) then
        shotPercent = (stats.twoPM + stats.threePM) / (stats.twoPA + stats.threePA)
    end
    
    local expRaw = (stats.points * shotPercent * 2.5) + (stats.steals + stats.blocks - stats.turnovers) * 5
    local factor = math.pow((player.potential / 20.0) + .5, player.years + 1)
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

    if(exp > 100) then
        exp = 100
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

        if(player and calculateOverall(player) < 10 and calculateOverall(player) < player.potential) then
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

function league:createNewStats()
    for i = 1, 30 do
        local team = self.teams[i]

        for j = 1, #team.players do
            local player = team.players[j]

            table.insert(player.stats, StatsLib:createStats())
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

            if(away.wins < 4 and home.wins < 4) then
                if((game.away ~= userTeam and game.home ~= userTeam) or simulateMainGame) then
                    local score = simulateGame(self:findTeam(game.away), self:findTeam(game.home))
                    game.score = score

                    if(game.score.away >= game.score.home) then
                        away.wins = away.wins + 1
                    else
                        home.wins = home.wins + 1
                    end
                end

                self:giveExp(game.away)
                self:giveExp(game.home)
            end
        else
            if((game.away ~= userTeam and game.home ~= userTeam) or simulateMainGame) then
                local score = simulateGame(self:findTeam(game.away), self:findTeam(game.home))
                game.score = score
            end

            self:giveExp(game.away)
            self:giveExp(game.home)
        end
    end

    simulateMainGame = false
    self.weekNum = self.weekNum + 1
    self:createNewStats()
end

local function changeStamina(player, diff)
    player.stamina = player.stamina + diff

    if(player.stamina > player.maxStamina) then
        player.stamina = player.maxStamina
    elseif(player.stamina < 1) then
        player.stamina = 1
    end
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
        return calculateOverall(a) > calculateOverall(b)
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
        team.players[i].last5 = {}
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
    
    if(regularSeason) then
        if(score.home > score.away) then
            home.wins = home.wins + 1
            away.losses = away.losses + 1
        else
            away.wins = away.wins + 1
            home.losses = home.losses + 1
        end 
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
    local turnoverProb = turnoverAverage + ((defender.stealing - player.dribbling) * 2)

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
        local offenseStats = offense.players[i].stats[#offense.players[i].stats]
        local defenseStats = defense.players[i].stats[#defense.players[i].stats]

        offenseStats.plusMinus = offenseStats.plusMinus + points
        defenseStats.plusMinus = defenseStats.plusMinus - points
    end
end

function simulatePossession(offense, defense, defenseStrategy)
    local defensiveStrategy = defenseStrategy or 1
    subPlayers(offense)

    local teamStarters = {unpack(offense.players, 1, 5)}
    table.sort(teamStarters, function (a, b) 
        local closeA = a.finishing + a.closeShot
        local midA = a.closeShot + a.midRange
        local longA = a.midRange + a.three

        local closeB = b.finishing + b.closeShot
        local midB = b.closeShot + b.midRange
        local longB = b.midRange + b.three

        local maxA = 0
        if(closeA >= midA and closeA >= longA) then
            maxA = closeA
        elseif(midA >= closeA and midA >= longA) then
            maxA = midA
        else
            maxA = longA
        end
        
        local maxB = 0
        if(closeB >= midB and closeB >= longB) then
            maxB = closeB
        elseif(midB >= closeB and midB >= longB) then
            maxB = midB
        else
            maxB = longB
        end

        return maxA > maxB
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

    local playerStats = player.stats[#player.stats]
    local defenderStats = defender.stats[#defender.stats]

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
        playerStats.turnovers = playerStats.turnovers + 1
        defenderStats.steals = defenderStats.steals + 1
        message = "Stolen"

        time = time / 2
        if(time < 6) then
            time = 6
        end
    elseif(blocked(player, defender)) then
        points = 0
        defenderStats.blocks = defenderStats.blocks + 1
        defenderStats.shotsAgainst = defenderStats.shotsAgainst + 1
        message = "Blocked"
    end

    changeTeamStamina(offense, defense, player, defender)

    if shotPoints == 2 then
        defenderStats.shotsAgainst = defenderStats.shotsAgainst + 1
        defenderStats.pointsAgainst = defenderStats.pointsAgainst + points
        playerStats.twoPA = playerStats.twoPA + 1

        if points ~= 0 then
            adjustPlusMinus(offense, defense, 2)
            playerStats.points = playerStats.points + 2
            playerStats.twoPM = playerStats.twoPM + 1
        end
    else
        defenderStats.shotsAgainst = defenderStats.shotsAgainst + 1
        defenderStats.pointsAgainst = defenderStats.pointsAgainst + points
        playerStats.threePA = playerStats.threePA + 1

        if points ~= 0 then
            adjustPlusMinus(offense, defense, 3)
            playerStats.points = playerStats.points + 3
            playerStats.threePM = playerStats.threePM + 1
        end
    end
    
    addToLast5(player, points)
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
    --local scaling = (shooterSkill - defenderSkill) * skillScaling * heightFactor
    local scaling = (shooterSkill * 3 - defenderSkill * 2.5) * heightFactor
    local wideOpen = wideOpenShot(player, defender)

    if(wideOpen) then
        scaling = shooterSkill * skillScaling
    end

    local percentageMade = leagueAvg + scaling

    local streak = getStreak(player)
    if(streak == ICE_COLD_STR) then
        percentageMade = percentageMade * ICE_COLD_FACTOR
    elseif(streak == COLD_STR) then
        percentageMade = percentageMade * COLD_FACTOR
    elseif(streak == HOT_STR) then
        percentageMade = percentageMade * HOT_FACTOR
    elseif(streak == LAVA_HOT_STR) then
        percentageMade = percentageMade * LAVA_HOT_FACTOR
    end

    if(shotPercent <= percentageMade) then
        return maxPoints
    else
        return 0
    end
end

function league:resignPlayers()
    for i = 1, #self.teams do
        if(self.teams[i].name ~= userTeam) then
            resignPlayers(self.teams[i])
        end
    end
end

function league:nextYear()
    regularSeason = true
	playoffs = false
    preseason = true
	
	self.year = self.year + 1
	self.weekNum = 1
	self.regularSeason = true
	self.playoffsActive = false
	self:createSchedule()

	for i = 1, 30 do
		local team = self.teams[i]
		team.wins = 0
		team.losses = 0
        adjustCap(team)

		for j = 1, #team.players do
			local player = team.players[j]
			
            agePlayer(player)
		end
	end
end

function league:freeAgentOffers(player, offer)
    local offers = {}
    local fairSalary = calculateFairSalary(player)
    local overall = calculateOverall(player)

    for i = 1, #self.teams do
        local team = self.teams[i]

        if(team.name ~= userTeam) then
            if(calculateCap(team) + fairSalary < team.cap and #team.players < 15) then
                local max = team.cap - calculateCap(team)
                if(max > CONTRACT_MAX) then
                    max = CONTRACT_MAX
                end

                local percentBetter = overall / calculateStarterOverall(team)
                local offerValue = percentBetter * fairSalary

                if(offerValue > max) then
                    offerValue = max
                elseif(offerValue < fairSalary) then
                    offerValue = fairSalary
                end

                offerValue = math.round(offerValue)

                table.insert(offers, OfferLib:createOffer(team, player, offerValue, 4))
            end
        elseif(offer) then
            table.insert(offers, offer)
        end
    end

    if(#offers > 0) then
        table.sort(offers, function (a, b)
            return offerRating(a, fairSalary) > offerRating(b, fairSalary)
        end)
    
        local winningOffer = offers[1]

        player.contract.value = winningOffer.salary
        player.contract.length = winningOffer.length
    
        table.insert(winningOffer.team.players, player)
        table.remove(self.freeAgents, indexOf(self.freeAgents, player))

        return winningOffer.team.name
    end

    return ""
end

function league:readjustStarters()
    for i = 1, #self.teams do
        local team = self.teams[i]

        table.sort(team.players, function (a, b)
            return calculateOverall(a) > calculateOverall(b)
        end)

        for j = 1, #team.players do
            if(j <= 5) then
                team.players[j].starter = true
            else
                team.players[j].starter = false
            end
		end
    end
end

return league