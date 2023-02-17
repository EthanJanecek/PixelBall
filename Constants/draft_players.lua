local PlayerLib = require("Objects.player")

draftPlayers = {}

function generateDraftPlayers()
    local i = 1
    while #draftPlayers < 60 do
        local player = PlayerLib:createRookie()

        if(i <= 3) then
            if(calculateOverall(player) > 4.25) then
                table.insert(draftPlayers, player)
                i = i + 1
            end
        elseif(i <= 14) then
            if(calculateOverall(player) > 3.5 and calculateOverall(player) < 4.5) then
                table.insert(draftPlayers, player)
                i = i + 1
            end
        elseif(i <= 30) then
            if(calculateOverall(player) > 2.5 and calculateOverall(player) < 4) then
                table.insert(draftPlayers, player)
                i = i + 1
            end
        else
            if(calculateOverall(player) > 1.5 and calculateOverall(player) < 3) then
                table.insert(draftPlayers, player)
                i = i + 1
            end
        end
    end
end