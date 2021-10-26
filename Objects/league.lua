local TeamLib = require("Objects.team")
local league = {}
local StartPositions = require("Constants.start_positions")

local leagueAvg2 = 47
local leageAvg3 = 37
local percentShots2 = 72
local skillScaling = 3
local playerPercentages = {40, 70, 85, 95, 100}
local heightDiffMin = 5
local heightDiffMax = 15

function league:createLeague()
    self.__index = self

    return setmetatable({
        teams=createTeams(),
        weekNum=1,
        schedule={}
    }, self)
end

function createTeams()
    local teams = {}

    -- Eastern Conference
    -- Atlantic Division
    table.insert(teams, TeamLib:create("76ers", "PHI", "images/logos/76ers.png", "East", "Atlantic", "blue", "Data/76ers_roster.csv"))
    table.insert(teams, TeamLib:create("Nets", "BKN", "images/logos/nets.png", "East", "Atlantic", "black", "Data/nets_roster.csv"))
    table.insert(teams, TeamLib:create("Celtics", "BOS", "images/logos/celtics.png", "East", "Atlantic", "green", "Data/celtics_roster.csv"))
    table.insert(teams, TeamLib:create("Raptors", "TOR", "images/logos/raptors.png", "East", "Atlantic", "red", "Data/raptors_roster.csv"))
    table.insert(teams, TeamLib:create("Knicks", "NYK", "images/logos/knicks.png", "East", "Atlantic", "blue", "Data/knicks_roster.csv"))

    -- Central Division
    table.insert(teams, TeamLib:create("Bucks", "MIL", "images/logos/bucks.png", "East", "Central", "green", "Data/bucks_roster.csv"))
    table.insert(teams, TeamLib:create("Pacers", "IND", "images/logos/pacers.png", "East", "Central", "yellow", "Data/pacers_roster.csv"))
    table.insert(teams, TeamLib:create("Pistons", "DET", "images/logos/pistons.png", "East", "Central", "blue", "Data/pistons_roster.csv"))
    table.insert(teams, TeamLib:create("Bulls", "CHI", "images/logos/bulls.png", "East", "Central", "red", "Data/bulls_roster.csv"))
    table.insert(teams, TeamLib:create("Cavaliers", "CLE", "images/logos/cavaliers.png", "East", "Central", "black", "Data/cavaliers_roster.csv"))

    -- Southeast Division
    table.insert(teams, TeamLib:create("Heat", "MIA", "images/logos/heat.png", "East", "Southeast", "red", "Data/heat_roster.csv"))
    table.insert(teams, TeamLib:create("Magic", "ORL", "images/logos/magic.png", "East", "Southeast", "blue", "Data/magic_roster.csv"))
    table.insert(teams, TeamLib:create("Hawks", "ATL", "images/logos/hawks.png", "East", "Southeast", "red", "Data/hawks_roster.csv"))
    table.insert(teams, TeamLib:create("Wizards", "WAS", "images/logos/wizards.png", "East", "Southeast", "blue", "Data/wizards_roster.csv"))
    table.insert(teams, TeamLib:create("Hornets", "CHA", "images/logos/hornets.png", "East", "Southeast", "blue", "Data/hornets_roster.csv"))

    -- Western Conference
    -- Pacific Division
    table.insert(teams, TeamLib:create("Lakers", "LAL", "images/logos/lakers.png", "West", "Pacific", "yellow", "Data/lakers_roster.csv"))
    table.insert(teams, TeamLib:create("Clippers", "LAC", "images/logos/clippers.png", "West", "Pacific", "blue", "Data/clippers_roster.csv"))
    table.insert(teams, TeamLib:create("Suns", "PHX", "images/logos/suns.png", "West", "Pacific", "purple", "Data/suns_roster.csv"))
    table.insert(teams, TeamLib:create("Warriors", "GSW", "images/logos/warriors.png", "West", "Pacific", "blue", "Data/warriors_roster.csv"))
    table.insert(teams, TeamLib:create("Kings", "SAC", "images/logos/kings.png", "West", "Pacific", "purple", "Data/kings_roster.csv"))

    -- Northwest Division
    table.insert(teams, TeamLib:create("Nuggets", "DEN", "images/logos/nuggets.png", "West", "Northwest", "blue", "Data/nuggets_roster.csv"))
    table.insert(teams, TeamLib:create("Jazz", "UTA", "images/logos/jazz.png", "West", "Northwest", "orange", "Data/jazz_roster.csv"))
    table.insert(teams, TeamLib:create("Trail Blazers", "POR", "images/logos/trail blazers.png", "West", "Northwest", "black", "Data/trailblazers_roster.csv"))
    table.insert(teams, TeamLib:create("Thunder", "OKC", "images/logos/thunder.png", "West", "Northwest", "blue", "Data/thunder_roster.csv"))
    table.insert(teams, TeamLib:create("Timberwolves", "MIN", "images/logos/timberwolves.png", "West", "Northwest", "blue", "Data/timberwolves_roster.csv"))

    -- Southwest Division
    table.insert(teams, TeamLib:create("Rockets", "HOU", "images/logos/rockets.png", "West", "Southwest", "red", "Data/rockets_roster.csv"))
    table.insert(teams, TeamLib:create("Spurs", "SAS", "images/logos/spurs.png", "West", "Southwest", "black", "Data/spurs_roster.csv"))
    table.insert(teams, TeamLib:create("Pelicans", "NOP", "images/logos/pelicans.png", "West", "Southwest", "red", "Data/pelicans_roster.csv"))
    table.insert(teams, TeamLib:create("Mavericks", "DAL", "images/logos/mavericks.png", "West", "Southwest", "blue", "Data/mavericks_roster.csv"))
    table.insert(teams, TeamLib:create("Grizzlies", "MEM", "images/logos/grizzlies.png", "West", "Southwest", "cyan", "Data/grizzlies_roster.csv"))

    return teams
end

function league:shuffleGames()
    for j = 1, 200 do
        -- Shuffle weekly games 50 times
        local old = math.random(1, 72)
        local new = math.random(1, 72)
        self.schedule[old], self.schedule[new] = self.schedule[new], self.schedule[old]
    end
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
    for i = 1, 100 do
        local weeklySchedule = {}
        table.insert(self.schedule, weeklySchedule)
    end

    for i = 1, 30 do
        local team1 = self.teams[i]
        local weekNum = 1

        for j = i + 1, 30 do
            local team2 = self.teams[j]

            local numGames = 2
            if(team1.conf == team2.conf) then
                numGames = 3
            end

            for k = 1, numGames do
                if(weekNum > #self.schedule) then
                    weekNum = 1
                end

                while(checkIfTeamPlays(self.schedule[weekNum], team1.name) or checkIfTeamPlays(self.schedule[weekNum], team2.name)) do
                    weekNum = weekNum + 1

                    if(weekNum > #self.schedule) then
                        weekNum = 1
                    end
                end
                
                if(k % 2 == 0) then
                    table.insert(self.schedule[weekNum], {away=team1.name, home=team2.name})
                else
                    table.insert(self.schedule[weekNum], {away=team2.name, home=team1.name})
                end
                
                weekNum = weekNum + 1
            end
        end
    end

    self:shuffleGames()
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

function league:nextWeek()
    local allGames = self.schedule[self.weekNum]

    for i = 1, #allGames do
        local game = allGames[i]
        if(game.away ~= userTeam and game.home ~= userTeam) then
            simulateGame(self:findTeam(game.away), self:findTeam(game.home))
        end
    end

    print()
    self.weekNum = self.weekNum + 1
end


function simulateGame(away, home)
    local index = math.random(1, 2)
    local maxTime = 4 * minutesInQtr * 60
    local time = 0
    local score = {away = 0, home = 0}

    while time <= maxTime do
        if index % 2 == 0 then
            local result = simulatePossession(home, away)
            score.home = score.home + result.points
            time = time + result.time
        else
            local result = simulatePossession(away, home)
            score.away = score.away + result.points
            time = time + result.time
        end

        index = index + 1
    end

    -- Don't allow ties
    while(score.home == score.away) do
        -- Simulate 5 possessions each
        for i = 1, 5 do
            local result = simulatePossession(home, away)
            score.home = score.home + result.points
            time = time + result.time

            result = simulatePossession(away, home)
            score.away = score.away + result.points
            time = time + result.time
        end
    end
    
    -- TODO: Store results somewhere
    print(away.abbrev .. ": " .. score.away .. " - " .. home.abbrev .. ": " .. score.home)
end

function simulatePossession(offense, defense)
    local teamStarters = {unpack(offense.players, 1, 5)}
    table.sort(teamStarters, function (a, b)
        return (a.shooting + a.finishing) > (b.shooting + b.finishing)
    end)

    local opponentStarters = {unpack(defense.players, 1, 5)}
    table.sort(opponentStarters, function (a, b)
        return a.contesting > b.contesting
    end)

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

    local shotTypeBounds = 50 + (player.finishing - player.shooting) * 5
    local shotType = math.random(100)
    local shotPercent = math.random(100)
    local time = math.random(6, 24)
    local points = 0

    local heightDiff = player.height - defender.height + 10 -- Will be from 0-20
    if(heightDiff < heightDiffMin) then
        heightDiff = heightDiffMin
    elseif(heightDiff > heightDiffMax) then
        heightDiff = heightDiffMax
    end

    if(shotType <= shotTypeBounds) then
        -- 2
        local percentageMade = leagueAvg2 + (player.finishing - defender.contesting) * skillScaling * (heightDiff / 10)

        if(shotPercent <= percentageMade) then
            points = 2
        end
    else
        -- 3
        local percentageMade = leageAvg3 + (player.shooting - defender.contesting) * skillScaling * (heightDiff / 10)

        if(shotPercent <= percentageMade) then
            points = 3
        end
    end

    return {points=points, time=time}
end

return league