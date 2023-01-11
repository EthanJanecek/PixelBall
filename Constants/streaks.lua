ICE_COLD_MAX = 0
COLD_MAX = 3
HOT_MIN = 8
LAVA_HOT_MIN = 11

NONE_STR = "NONE"
ICE_COLD_STR = "ICE_COLD"
COLD_STR = "COLD"
HOT_STR = "HOT"
LAVA_HOT_STR = "LAVA_HOT"

ICE_COLD_FACTOR = .6
COLD_FACTOR = .8
HOT_FACTOR = 1.2
LAVA_HOT_FACTOR = 1.4

function getStreak(player)
    if(#player.last5 ~= 5) then
        return NONE_STR
    else
        local sum = 0

        for i = 1, 5 do
            sum = sum + player.last5[i]
        end

        if(sum <= ICE_COLD_MAX) then
            return ICE_COLD_STR
        elseif(sum <= COLD_MAX) then
            return COLD_STR
        elseif(sum >= LAVA_HOT_MIN) then
            return LAVA_HOT_STR
        elseif(sum >= HOT_MIN) then
            return HOT_STR
        else
            return NONE_STR
        end
    end
end