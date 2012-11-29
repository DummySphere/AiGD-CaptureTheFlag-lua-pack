
local BalancedCommander = class(Commander)

error("TODO: BalancedCommander")
--[[
class BalancedCommander : public Commander
{
private:
    Vector2 getFlankingPosition(BotInfo* bot, Vector2 target)

    BotInfo *attacker
    BotInfo *defender
    Vector2 middle, left, right, front
end

REGISTER_COMMANDER(BalancedCommander)


function BalancedCommander:getName()
    -- change this to return the commander name
    return "BalancedCommander"
end


function BalancedCommander:initialize()
    -- do stuff in here before the game starts
    self.attacker = nil
    self.defender = nil

    -- Calculate flag positions and  store the middle->
    local ours = self.game.team.flag.position
    local theirs = self.game.enemyTeam.flag.position
    self.middle = (theirs + ours) / 2.0f

    local d = (ours - theirs)    
    self.left = Vector2(-d.y, d.x).normalisedCopy()
    self.right = Vector2(d.y, -d.x).normalisedCopy()
    self.front = Vector2(d.x, d.y).normalisedCopy()
end


function BalancedCommander:tick()
    -- the attacker is dead we"ll pick another when available
    if(self.attacker and *self.attacker.health <= 0)
        self.attacker = nil

    -- the defender is dead we"ll pick another when available
    if( self.defender and  (*self.defender.health <= 0 or self.defender.flag))
        self.defender = nil

    -- In this example we loop through all living bots without orders (self.game.bots_available)
    -- All other bots will wander randomly
    for (size_t i=0; i< self.game.bots_available.size(); ++i)
        local bot = self.game.bots_available[i]
        if( (self.defender == nil or self.defender == bot) and  not bot.flag)
            self.defender = bot

            -- Stand on a random position in a box of 4m around the flag->
            local targetPosition = self.game.team.flagScoreLocation
            local targetMin = targetPosition - Vector2(2.0f, 2.0f)
            local targetMax = targetPosition + Vector2(2.0f, 2.0f)
            local goal = targetPosition
            self.level.findRandomFreePositionInBox(goal, targetMin, targetMax)

            if( (goal - *bot.position).length() > 8.0f)
                self:issue(ChargeCommand(self.defender.name, goal, "running to defend"))
            else
                self:issue(DefendCommand(self.defender.name, (self.middle - *bot.position), "turning to defend"))
			end
        else if (self.attacker == nil or self.attacker == bot or bot.flag)
            -- Our attacking bot
            self.attacker = bot
            if( bot.flag)
                -- Tell the flag carrier to run home!
                local target = self.game.team.flagScoreLocation
                self:issue(MoveCommand(bot.name, target, "running home"))
            else
                local target = self.game.enemyTeam.flag.position
                local flank = getFlankingPosition(bot, target)
                if( (target - flank).length() > (*bot.position - target).length())
                    self:issue(AttackCommand(bot.name, target, target, "attack from flank"))
                else
                    self.level.findNearestFreePosition(flank, flank)
                    self:issue(MoveCommand(bot.name, flank, "running to flank"))
                end
            end
        else
            -- All our other (random) bots

            -- pick a random position in the level to move to                               
            local minSide = min(self.level.width, self.level.height)
            local box = Vector2((float)minSide,(float)minSide)
            local target

            -- issue the order
            if(self.level.findRandomFreePositionInBox(target, self.middle + box * 0.4f, self.middle - box * 0.4f))
                self:issue(AttackCommand(bot.name, target, boost:none,"random patrol"))
        end
    end
end   


function BalancedCommander:shutdown()
    -- do stuff in here after the game finishes
end

function BalancedCommander:getFlankingPosition( BotInfo* bot, Vector2 target )
    local flanks[]  =  {target + self.left*16.0f, target + self.right*16.0fend
    local options
    for(int i=0; i<2; ++i)
    {
        local val
        if(self.level.findNearestFreePosition(val, flanks[i]))
            options.push_back(val)
    end

    local bestDist = FLT_MAX
    local bestOption = target
    for (size_t i=0; i<options.size(); ++i)
    {
        local dist = (options[i]-*bot.position).length()
        if(dist < bestDist)
        {
            bestDist = dist
            bestOption = options[i]
        end
    end
    return bestOption
end
]]

return BalancedCommander
