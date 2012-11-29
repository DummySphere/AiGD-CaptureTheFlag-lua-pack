
local DefenderCommander = class(Commander)

function DefenderCommander:new(...)
	Commander.new(self, ...)
	-- Custom constructor here
end

function DefenderCommander:getName()
    -- Change this to return the commander name
    return "DefenderCommander"
end


function DefenderCommander:initialize()
    -- Do stuff in here before the m_game starts
    self.attacker = nil
end


function DefenderCommander:tick()
    -- TODO: When defender is down to the last bot that"s attacking the flag, it"ll end up ordering
    -- the attacker to run all the way back from the flag to defend!
    if self.attacker and self.attacker.health <= 0 then
        self.attacker = nil
	end

	for _, bot in ipairs(self.game.bots_available) do
        if (not self.attacker or self.attacker == bot) and #self.game.bots_available > 1 then
            if bot.flag then
                --bring it hooome
                self:issue(ChargeCommand(bot.name, { target = self.game.team.flagScoreLocation }, "returning enemy flag!"))
            else
                -- find the closest flag that isn't ours
                self:issue(ChargeCommand(bot.name, { target = self.game.enemyTeam.flag.position }, "getting enemy flag!"))
            end
            self.attacker = bot
        else
            if self.attacker == bot then
				self.attacker = nil
			end

            -- defend the flag!
            local targetPosition = self.game.team.flagScoreLocation
			local areaRadius = 8
            local targetMin = Vector2.sub(targetPosition, { areaRadius, areaRadius })
            local targetMax = Vector2.add(targetPosition, { areaRadius, areaRadius })
            if bot.flag then
                --bring it hooome
                self:issue(ChargeCommand(bot.name, { target = self.game.team.flagScoreLocation }, "returning enemy flag!"))
            elseif bot.position then
				local dist = Vector2.distance(bot.position, targetPosition)
                if dist > 9 and dist > 3 then
                    for i = 1, 100 do
                        local position = self.level:findRandomFreePositionInBox(targetMin, targetMax) -- or targetPosition
                        if position and Vector2.distance(position, targetPosition) > 3 then
                            self:issue(MoveCommand(bot.name, position, "defending around flag"))
                            break
                        end
                    end
                else 
                    self:issue(DefendCommand(bot.name, Vector2.sub(targetPosition, bot.position), "defending facing flag"))
				end
            end
        end
    end
end


function DefenderCommander:shutdown()
    -- do stuff in here after the game finishes
end

return DefenderCommander
