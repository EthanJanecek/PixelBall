PlayLib = require("Objects.play")
DefenseLib = require("Objects.defense")

local playbook = {}

function playbook:createPlaybook()
    self.__index = self

    return setmetatable({
        plays={PlayLib:createIsoPlay()},
        defensePlays={DefenseLib:createDefensePlay()}
    }, self)
end

function playbook:findPlay(name)
    for i = 1, #self.plays do
        play = self.plays[i]
        if(play.name == name) then
            return play
        end
    end

    return self.plays[1]
end

function playbook:findDefense(name)
    for i = 1, #self.plays do
        play = self.defensePlays[i]
        if(play.name == name) then
            return play
        end
    end

    return self.defensePlays[1]
end

return playbook