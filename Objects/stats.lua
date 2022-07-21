local stats = {}

function stats:createStats()
    self.__index = self

    return setmetatable({
        points = 0,
        twoPA = 0,
        twoPM = 0,
        threePA = 0,
        threePM = 0,
        blocks = 0,
        steals = 0,
        turnovers = 0
    }, self)
end


function stats:addStats(otherStats)
    self.points = self.points + otherStats.points
    self.twoPA = self.twoPA + otherStats.twoPA
    self.twoPM = self.twoPM + otherStats.twoPM
    self.threePA = self.threePA + otherStats.threePA
    self.threePM = self.threePM + otherStats.threePM
    self.blocks = self.blocks + otherStats.blocks
    self.steals = self.steals + otherStats.steals
    self.turnovers = self.turnovers + otherStats.turnovers
end

return stats