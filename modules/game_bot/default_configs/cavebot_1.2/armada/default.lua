local target

macro(10, "New AttackSpeed", "", function()
    if g_game.isAttacking() and not target then
        target = g_game.getAttackingCreature()
    end

    if target and g_game.isAttacking() and getDistanceBetween(pos(), target:getPosition()) <= 8 and not isInPz() then
        local atk = OutputMessage.create()
        local protocol = g_game.getProtocolGame()
        local id = target:getId()
        atk:addU8(161)
        atk:addU32(id)
        for i = 10, 1, -1 do
            if i > 1 then
                protocol:send(atk)
            end
        end
    end

    if not g_game.isAttacking() and target ~= nil then
        target = nil
    end
end)

onCreatureDisappear(function(creature)
    if target then
        if creature:getId() == target:getId() then
            target = nil
        end
    end
end)
