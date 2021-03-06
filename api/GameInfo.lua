
require "class"
require "Vector2"

----------------------------------------------------------------------
-- LevelInfo
-- Provides information about the level the game is played in

LevelInfo = class()

function LevelInfo:new(_table)
    assert(_table.width and _table.height and _table.blockHeights)
    self.width = _table.width                                          -- The width of the game world
    self.height = _table.height                                        -- The height of the game world
    self.blockHeights = _table.blockHeights                            -- A 2D table showing the height of the block at each position in the world
                                                                       -- indexing is based on [x + 1][y + 1]
	setmetatable(self.blockHeights, { __call = function(self, _x, _y)  -- Coordinates are from {0, 0} to {width - 1, height - 1}
		local v = Vector2(_x, _y)
		local ix, iy = math.floor(v.x) + 1, math.floor(v.y) + 1
		local col = self[ix]
		if col == nil then
			return -1
		end
		return col[iy] or -1
	end })
	
    assert(_table.teamNames and _table.flagSpawnLocations and _table.flagScoreLocations and _table.botSpawnAreas)
    self.teamNames = _table.teamNames                                  -- A list of the team names supported by this level.
    self.flagSpawnLocations = _table.flagSpawnLocations                -- The map of team name the spawn location of the team's flag
    self.flagScoreLocations = _table.flagScoreLocations                -- The map of team name the location the flag must be taken to score
    self.botSpawnAreas = _table.botSpawnAreas                          -- The map of team name the extents of each team's bot spawn area

    assert(_table.characterRadius and _table.FOVangle and _table.firingDistance and _table.walkingSpeed and _table.runningSpeed)
    self.characterRadius = _table.characterRadius                      -- The radius of each character, used to determine the passability region around blocks
    self.FOVangle = _table.FOVangle                                    -- The visibility radius of the bots
    self.firingDistance = _table.firingDistance                        -- The maximum firing distance of the bots
    self.walkingSpeed = _table.walkingSpeed                            -- The walking speed of the bots
    self.runningSpeed = _table.runningSpeed                            -- The running speed of the bots
    self.gameLength = _table.gameLength                                -- The time (seconds) that a game will last
    self.initializationTime = _table.initializationTime                -- The time (seconds) allowed to the commanders for initialization
    self.respawnTime = _table.respawnTime                              -- The time (seconds) between bot respawns
end

function LevelInfo:findRandomFreePositionInBox(_min, _max)
    -- Find a random position for a character to move to in an area.
    -- nil is returned if no position could be found.
    local minX, minY = math.min(math.max(0, _min.x), self.width - 1), math.min(math.max(0, _min.y), self.height - 1)
    local maxX, maxY = math.min(math.max(0, _max.x), self.width - 1), math.min(math.max(0, _max.y), self.height - 1)
    local rangeX, rangeY = maxX - minX, maxY - minY

    if rangeX == 0 or rangeY == 0 then
		print(string.format("no free random position found in range [{ %d, %d }, { %d, %d }] (rangeX = %d, rangeY = %d)", _min.x, _min.y, _max.x, _max.y, rangeX, rangeY))
        return
    end

	local blocks = self.blockHeights
	local characterRadius = self.characterRadius
	
    for i = 0, 99 do
        local x = math.random() * rangeX + minX
        local y = math.random() * rangeY + minY
		assert(blocks(x, y) >= 0, string.format("no block with coordinate [x = %d, y = %d] (width = %d, height = %d) (#width = %d, #height = %d)", x, y, self.width, self.height, #blocks, #blocks[1]))
        local ix, iy = math.floor(x), math.floor(y)

        local valid = true
        -- check if there are any blocks under current position
        valid = valid and (blocks(ix, iy) == 0)
        
        -- check if there are any blocks in the four cardinal directions
        valid = valid and not ((x - ix) < characterRadius and ix > 0 and blocks(ix - 1, iy) > 0)
        valid = valid and not ((ix + 1 - x) < characterRadius and ix < self.width - 1 and blocks(ix + 1, iy) > 0)
        valid = valid and not ((y - iy) < characterRadius and iy > 0 and blocks(ix, iy - 1) > 0)
        valid = valid and not ((iy + 1 - y) < characterRadius and iy < self.height - 1 and blocks(ix, iy + 1) > 0)

        -- check if there are any blocks in the four diagonals
        valid = valid and not ((x - ix) < characterRadius and (y - iy) < characterRadius and ix > 0 and iy > 0 and blocks(ix - 1, iy - 1) > 0)
        valid = valid and not ((ix + 1 - x) < characterRadius and (y - iy) < characterRadius and ix < self.width - 1 and iy > 0 and blocks(ix + 1, iy - 1) > 0)
        valid = valid and not ((x - ix) < characterRadius and (iy + 1 - y) < characterRadius and ix > 0 and iy < self.height - 1 and blocks(ix - 1, iy + 1) > 0)
        valid = valid and not ((x + 1 - ix) < characterRadius and (iy + 1 - y) < characterRadius and ix < self.width - 1 and iy < self.height - 1 and blocks(ix + 1, iy + 1) > 0)

        if valid then
            return Vector2(x, y)
        end
    end
	print(string.format("no free random position found in range [{ %d, %d }, { %d, %d }] (width = %d, height = %d)", _min.x, _min.y, _max.x, _max.y, self.width, self.height))
end

function LevelInfo:findNearestFreePosition(_position)
    for i = 0, 9 do
        local areaMin = Vector2(_position.x - i, _position.y - i)
        local areaMax = Vector2(_position.x + i, _position.y + i)
        
        local rand_pos = self:findRandomFreePositionInBox(areaMin, areaMax)
        if rand_pos then
            return rand_pos
        end
    end
end

----------------------------------------------------------------------
-- GameInfo
-- All of the filtered read-only information about the current game state.
-- This shouldn't be modified. Modifying it will only hurt yourself.
-- Updated each frame to show the current known information about the world.

GameInfo = class()

function GameInfo:new(_table)
    self.match = _table.match                                          -- The MatchInfo describing the current match
    self.teams = _table.teams                                          -- Map of team names to TeamInfo
    self.team = _table.team                                            -- The team this commander is controlling
    self.enemyTeam = _table.enemyTeam                                  -- The enemy team for this commander
    self.bots = _table.bots                                            -- Map of bot name to BotInfo
    self.flags = _table.flags                                          -- Map of flag name to FlagInfo

	self:updateLists()
end

function GameInfo:merge(_otherGame, _cumulative)
	self.match:merge(_otherGame.match, self, _cumulative)
	for name, team in pairs(self.teams) do
		team:merge(_otherGame.teams[name], self)
	end
	assert(self.team.name == _otherGame.team.name)
	assert(self.enemyTeam.name == _otherGame.enemyTeam.name)
	for name, bot in pairs(self.bots) do
		bot:merge(_otherGame.bots[name], self)
	end
	for name, flag in pairs(self.flags) do
		flag:merge(_otherGame.flags[name], self)
	end
	
	self:updateLists()
end

function GameInfo:updateLists()
    -- updated by the client wrapper before commander tick
	self.bots_alive = {}                                         		-- List of bots in the commander's team that are alive
	self.bots_available = {}                                     		-- List of bots in the commander's team that are alive and idle
	for _, bot in ipairs(self.team.members) do
		if bot.health > 0 then
			table.insert(self.bots_alive, bot)
			if bot.state == BotInfo.STATE_IDLE then
				table.insert(self.bots_available, bot)
			end
		end
	end
	self.enemyFlags = {}                                         		-- List of flags that don't belong to this commander's team
	for name, team in pairs(self.teams) do
		if team ~= self.team then
			table.insert(self.enemyFlags, team.flag)
		end
	end
end

----------------------------------------------------------------------
-- TeamInfo
-- Information about the current team including ids of all of the members of the team

TeamInfo = class()

function TeamInfo:new(_table)
    self.name = _table.name                                            -- The name of the team
    self.members = _table.members                                      -- The bots that are members of this team
    self.flag = _table.flag                                            -- The flag for this team
    self.flagSpawnLocation = _table.flagSpawnLocation                  -- The location where this team's flag is spawned
    self.flagScoreLocation = _table.flagScoreLocation                  -- The location where this team must take enemy flags to score
    self.botSpawnArea = _table.botSpawnArea                            -- The area in which this team's bots are spawned
end

function TeamInfo:merge(_otherTeam, _game)
	assert(self.name == _otherTeam.name)
	-- self.members - no need to update
	assert(self.flag.name == _otherTeam.flag.name)
    self.flagSpawnLocation = _otherTeam.flagSpawnLocation -- no need to update
    self.flagScoreLocation = _otherTeam.flagScoreLocation -- no need to update
    self.botSpawnArea = _otherTeam.botSpawnArea -- no need to update
end

----------------------------------------------------------------------
-- FlagInfo
-- Information about each of the flags.
-- The positions of all flags are always known.
-- If a flag is being carried the carrier is always known

FlagInfo = class()

function FlagInfo:new(_table)
    self.name = _table.name                                            -- The name of this flag
    self.team = _table.team                                            -- The team that owns this flag
    self.position = _table.position                                    -- The position of this flag
    self.carrier = _table.carrier                                      -- The bot carrying this flag, nil if the flag is not being carried
    self.respawnTimer = _table.respawnTimer                            -- The time remaining until the dropped flag is respawned
end

function FlagInfo:merge(_otherFlag, _game)
	assert(self.name == _otherFlag.name)
	assert(self.team.name == _otherFlag.team.name)
    self.position = _otherFlag.position
    self.carrier = _otherFlag.carrier and _game.bots[_otherFlag.carrier.name]
    self.respawnTimer = _otherFlag.respawnTimer
end

----------------------------------------------------------------------
-- BotInfo
-- Information that you know about each of the bots.
-- Enemy bots will contain information about the last time they were seen.
-- Friendly bots will contain full information.

BotInfo = class()

-- possible bot states
BotInfo.STATE_UNKNOWN = 0
BotInfo.STATE_IDLE = 1
BotInfo.STATE_DEFENDING = 2
BotInfo.STATE_MOVING = 3
BotInfo.STATE_ATTACKING = 4
BotInfo.STATE_CHARGING = 5
BotInfo.STATE_SHOOTING = 6
BotInfo.STATE_TAKINGORDERS = 7

function BotInfo:new(_table)
    self.name = _table.name                                            -- The name of the bot.
    self.team = _table.team                                            -- [The team this bot belongs to.
    self.health = _table.health                                        -- The last known health of the bot. 
                                                                       -- For enemy bots that have never been seen this value is not set
    self.state = _table.state                                          -- The last known state of the bot
                                                                       -- For enemy bots that have never been seen this value is not set
    self.position = _table.position                                    -- The last known position of the bot
                                                                       -- For enemy bots that have never been seen this value is not set
    self.facingDirection = _table.facingDirection                      -- The last known facing direction of the bot
                                                                       -- For enemy bots that have never been seen this value is not set
    self.seenlast = _table.seenlast                                    -- The time since the bot was last seen (0 if the bot was seen this frame).
    self.flag = _table.flag                                            -- The flag this bot is carrying, nullptr if the bot is not carrying a flag
    self.visibleEnemies = _table.visibleEnemies                        -- The list of bots that are visible to this bot
                                                                       -- For enemy bots that are not visible this will be an empty list
    self.seenBy = _table.seenBy                                        -- The list of bots that are seen by this bot
                                                                       -- For enemy bots that are not visible this will be an empty list
end

function BotInfo:merge(_otherBot, _game)
	assert(self.name == _otherBot.name)
	assert(self.team.name == _otherBot.team.name)
    self.health = _otherBot.health
    self.state = _otherBot.state
    self.position = _otherBot.position
    self.facingDirection = _otherBot.facingDirection
    self.seenlast = _otherBot.seenlast
    self.flag = _otherBot.flag and _game.flags[_otherBot.flag.name]
	
	self.visibleEnemies = {}
	for _, bot in ipairs(_otherBot.visibleEnemies) do
		table.insert(self.visibleEnemies, _game.bots[bot.name])
	end
	
	self.seenBy = {}
	for _, bot in ipairs(_otherBot.seenBy) do
		table.insert(self.seenBy, _game.bots[bot.name])
	end
end

----------------------------------------------------------------------
-- MatchInfo
-- Information about the current match.

MatchInfo = class()

function MatchInfo:new(_table)
    self.timeRemaining = _table.timeRemaining                          -- The time (seconds) remaining in this game.
    self.timeToNextRespawn = _table.timeToNextRespawn                  -- The time (seconds) until the next bot respawn cycle.
    self.combatEvents = _table.combatEvents                            -- The list of all events that have occured in this game.
end

function MatchInfo:merge(_otherMatch, _game, _cumulative)
    self.timeRemaining = _otherMatch.timeRemaining
    self.timeToNextRespawn = _otherMatch.timeToNextRespawn
	
	if not _cumulative then
		self.combatEvents = {}
	end
	
	for _, combatEvent in ipairs(_otherMatch.combatEvents) do
		local t = { type = combatEvent.type, time = combatEvent.time, instigator = combatEvent.instigator and _game.bots[combatEvent.instigator.name] }
		local subject = combatEvent.subject
		if subject then
			if subject:GetClass() == BotInfo then
				t.subject = _game.bots[combatEvent.subject.name]
			elseif subject:GetClass() == FlagInfo then
				t.subject = _game.flags[combatEvent.subject.name]
			else
				error("MatchInfo: unknown subject type " .. combatEvent.type)
			end
		end
		table.insert(self.combatEvents, MatchCombatEvent(t))
	end
end

----------------------------------------------------------------------
-- MatchCombatEvent
-- Information about a particular game event.

MatchCombatEvent = class()

MatchCombatEvent.TYPE_NONE = 0
MatchCombatEvent.TYPE_KILLED = 1
MatchCombatEvent.TYPE_FLAG_PICKEDUP = 2
MatchCombatEvent.TYPE_FLAG_DROPPED = 3
MatchCombatEvent.TYPE_FLAG_CAPTURED = 4
MatchCombatEvent.TYPE_FLAG_RESTORED = 5
MatchCombatEvent.TYPE_RESPAWN = 6

function MatchCombatEvent:new(_table)
    self.type = _table.type                                            -- The type of the event
    self.time = _table.time                                            -- The time (seconds since the start of the game) that the event occurred
    
    self.instigator = _table.instigator                                -- Depends on the event type.
                                                                       -- TYPE_KILLED: The bot that killed the other bot.
                                                                       -- TYPE_FLAG_PICKEDUP: The bot that picked the flag up.
                                                                       -- TYPE_FLAG_DROPPED: The bot that dropped the flag.
                                                                       -- TYPE_FLAG_CAPTURED: The bot that captured the flag. (took it to the scoring location)

    self.subject = _table.subject                                      -- Depends on the event type.
                                                                       -- TYPE_KILLED: The bot that was killed.
                                                                       -- TYPE_FLAG_PICKEDUP: The flag that was picked up.
                                                                       -- TYPE_FLAG_DROPPED: The flag that was dropped.
                                                                       -- TYPE_FLAG_CAPTURED: The flag that was captured.
                                                                       -- TYPE_FLAG_RESTORED: The flag that was restored.
                                                                       -- TYPE_RESPAWN: The bot that was spawned.
end
