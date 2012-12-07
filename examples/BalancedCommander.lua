
local BalancedCommander = class(Commander)

function BalancedCommander:new(...)
	Commander.new(self, ...)
	-- Custom constructor here
end

function BalancedCommander:getName()
    -- Change this to return the commander name
    return "BalancedCommander"
end

function BalancedCommander:initialize()
    -- Do stuff in here before the game starts
    self.attacker = nil
    self.defender = nil

    -- Calculate flag positions and  store the middle->
    local ours = self.game.team.flag.position
    local theirs = self.game.enemyTeam.flag.position
    self.middle = (theirs + ours) / 2

    local d = (ours - theirs):normalize()
    self.front = d
    self.left = Vector2(-d.y, d.x)
    self.right = Vector2(d.y, -d.x)
end

function BalancedCommander:tick()
    -- the attacker is dead we'll pick another when available
    if self.attacker and self.attacker.health <= 0 then
        self.attacker = nil
	end

    -- the defender is dead we'll pick another when available
    if self.defender and (self.defender.health <= 0 or self.defender.flag) then
        self.defender = nil
	end

    -- In this example we loop through all living bots without orders (self.game.bots_available)
    -- All other bots will wander randomly
	for _, bot in ipairs(self.game.bots_available) do
        if (self.defender == nil or self.defender == bot) and not bot.flag then
            self.defender = bot

            -- Stand on a random position in a box of 4m around the flag->
            local targetPosition = self.game.team.flagSpawnLocation
            local targetMin = targetPosition - Vector2(2, 2)
            local targetMax = targetPosition + Vector2(2, 2)
            local goal = self.level:findRandomFreePositionInBox(targetMin, targetMax) or targetPosition

            if Vector2.distance(goal, bot.position) > 8 then
                self:issue(ChargeCommand(self.defender.name, { target = goal }, "running to defend"))
            else
                self:issue(DefendCommand(self.defender.name, { target = (self.middle - bot.position) }, "turning to defend"))
			end
        elseif self.attacker == nil or self.attacker == bot or bot.flag then
            -- Our attacking bot
            self.attacker = bot
            if bot.flag then
                -- Tell the flag carrier to run home!
                local target = self.game.team.flagScoreLocation
                self:issue(MoveCommand(bot.name, { target = target }, "running home"))
            else
                local target = self.game.enemyTeam.flag.position
                local flank = self:getFlankingPosition(bot, target)
                if Vector2.distance(target, flank) > Vector2.distance(bot.position, target) then
                    self:issue(AttackCommand(bot.name, { target = target, lookAt = target }, "attack from flank"))
                else
                    flank = self.level:findNearestFreePosition(flank) or flank
                    self:issue(MoveCommand(bot.name, { target = flank }, "running to flank"))
                end
            end
        else
            -- All our other (random) bots

            -- pick a random position in the level to move to                               
            local minSide = math.min(self.level.width, self.level.height)
            local box = Vector2(minSide, minSide)
            local target = self.level:findRandomFreePositionInBox(self.middle + (box * 0.4), self.middle - (box * 0.4))

            -- issue the order
            if target then
                self:issue(AttackCommand(bot.name, { target = target }, "random patrol"))
			end
        end
    end
end   

function BalancedCommander:shutdown()
    -- do stuff in here after the game finishes
end

function BalancedCommander:getFlankingPosition(_bot, _target)
    local flanks = { _target + (self.left * 16), _target + (self.right * 16) }
    local options = {}
    for _, flank in ipairs(flanks) do
        local val = self.level:findNearestFreePosition(flank)
        if val then
            table.insert(options, val)
		end
    end

    local bestDist = math.huge
    local bestOption = _target
    for _, option in ipairs(options) do
        local dist = Vector2.distance(option, _bot.position)
        if dist < bestDist then
            bestDist = dist
            bestOption = option
        end
    end
    return bestOption
end

return BalancedCommander
