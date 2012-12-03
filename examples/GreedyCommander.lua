
local GreedyCommander = class(Commander)

function GreedyCommander:new(...)
	Commander.new(self, ...)
	-- Custom constructor here
end

function GreedyCommander:getName()
    -- change this to return the commander name
    return "GreedyCommander"
end

function GreedyCommander:initialize()
    -- Do stuff in here before the game starts
end

function GreedyCommander:tick()
    -- Process the bots that are waiting for orders, either send them all to attack or all to defend.

    local captured = not self.game.enemyTeam.flag.carrier

    local our_flag = self.game.team.flag.position
    local their_flag = self.game.enemyTeam.flag.position
    local their_base = self.game.enemyTeam.botSpawnArea[1]

    local option = math.random(3)
    local lookat
	if option == 1 or option == 2 then
		lookat = their_flag
	elseif option == 3 then
		lookat = their_base
	end

    -- Only process bots that are done with their orders...
	for _, bot in ipairs(self.game.bots_available) do
        if captured then
            local target = self.game.team.flagScoreLocation
            local closeEnoughDist = 8

            -- 1) Either run home, if this bot is the carrier or otherwise randomly.
            if bot.flag or math.random() < 0.5 or Vector2.distance(target, bot.position) > closeEnoughDist then
                self:issue(ChargeCommand(bot.name, { target = target }, "scrambling home"))
            else -- 2) Run to the exact flag location, effectively escorting the carrier.
                self:issue(AttackCommand(bot.name, { target = self.game.enemyTeam.flag.position, lookAt = lookat }, "attacking enemy flag"))
            end
        else
            local spawnArea = self.game.team.botSpawnArea
            local inSpawn =  (   bot.position[1] >= spawnArea[1][1]
                            and  bot.position[1] <= spawnArea[2][1]
                            and  bot.position[2] >= spawnArea[1][2]
                            and  bot.position[2] <= spawnArea[2][2])

            local path = {}
            table.insert(path, self.game.enemyTeam.flag.position)

            if inSpawn and math.random() < 0.5 then
                table.insert(path, self.game.team.flagScoreLocation)
			end

            self:issue(AttackCommand(bot.name, { target_list = path, lookAt = lookat }, "attacking enemy flag"))
        end
    end
end

function GreedyCommander:shutdown()
    -- Do stuff in here after the game finishes
end

return GreedyCommander
