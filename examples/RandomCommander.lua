
local RandomCommander = class(Commander)

function RandomCommander:new(...)
	Commander.new(self, ...)
	-- Custom constructor here
end

function RandomCommander:getName()
	-- Change this to return the commander name
	return "RandomCommander"
end

function RandomCommander:initialize()
	-- do stuff in here before the game starts
end

function RandomCommander:tick()
	-- Process all the bots that are done with their orders and available for taking commands.

	-- The 'bots_available' list is a dynamically calculated list of bots that are done with their commands.
	for _, bot in ipairs(self.game.bots_available) do
		-- Determine a place to run randomly...
		local target
		
		local rand = math.random(3)
		if rand == 1 then -- Either a random choice of *current* flag locations, ours or theirs.
			target = ((math.random() > 0.5) and self.game.team or self.game.enemyTeam).flag.position;
		elseif rand == 2 then -- Or a random choice of the goal locations for returning flags.
			target = ((math.random() > 0.5) and self.game.team or self.game.enemyTeam).flagScoreLocation;
		elseif rand == 3 then -- Or a random position in the entire level, one that's not blocked.
			target = self.level:findRandomFreePositionInBox({ 0, 0 }, { self.level.width - 1, self.level.height - 1 }) or bot.position
		end

		local rand = math.random(2)
		if rand == 1 then
			self:issue(AttackCommand(bot.name, { target = target }, "random"))
		elseif rand == 2 then
			self:issue(ChargeCommand(bot.name, { target = target }, "random"))
		end
	end
end

function RandomCommander:shutdown()
	-- do stuff in here after the game finishes
end

return RandomCommander
