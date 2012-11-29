
require "class"

----------------------------------------------------------------------
-- Command

Command = class()

function Command:new(_botId, _description)
	assert(_botId ~= nil, "an order must be given to a bot")
	self.botId = _botId
	self.description = _description or ""
end

----------------------------------------------------------------------
-- DefendCommand: Commands a bot to defend its current position.

DefendCommand = class(Command)

DefendCommand.FacingDirection = class()
function DefendCommand.FacingDirection:new(_direction, _time)
	self.direction = _direction
	self.time = _time or 0
end

-- @param botId The bot being ordered.
-- @param facingDirections The facing direction of the bot (can be a list of { direction, time }).
-- @param description A description of the intention of the bot. This can be optional displayed in the gui next to the bot label.
function DefendCommand:new(_botId, _params, _description)
	Command.new(self, _botId, _description)
	if _params and _params.facingDirection then
		self.facingDirections = { DefendCommand.FacingDirection(_params.facingDirection) }
	elseif _params and _params.facingDirection_list then
		self.facingDirections = {}
		for _, facingDirection in ipairs(_params.facingDirection_list) do
			table.insert(self.facingDirections, facingDirection)
		end
	else
		self.facingDirections = {}
	end
end

----------------------------------------------------------------------
-- MoveCommand: Commands a bot to run to a specified position without attacking visible enemies.

MoveCommand = class(Command)

-- @param botId The bot being ordered.
-- @param target The target location that the bot will move to.
-- @param description A description of the intention of the bot. This can be optional displayed in the gui next to the bot label.
function MoveCommand:new(_botId, _params, _description)
	Command.new(self, _botId, _description)
	if _params.target then
		self.target = { _params.target }
	elseif _params.target_list then
		self.target = {}
		for _, target in ipairs(_params.target_list) do
			table.insert(self.target_list, target)
		end
	else
		error("MoveCommand has no target given")
	end
end

----------------------------------------------------------------------
-- AttackCommand: Commands a bot to attack a specified position. If an enemy bot is seen by this bot, it will be attacked.

AttackCommand = class(Command)

-- @param botId The bot being ordered.
-- @param target The target location that the bot will attack.
-- @param lookAt An optional position which the bot should look at while moving.
-- @param description A description of the intention of the bot. This can be optional displayed in the gui next to the bot label.
function AttackCommand:new(_botId, _params, _description)
	Command.new(self, _botId, _description)
	if _params.target then
		self.target = { _params.target }
	elseif _params.target_list then
		self.target = {}
		for _, target in ipairs(_params.target_list) do
			table.insert(self.target_list, target)
		end
	else
		error("MoveCommand has no target given")
	end
	self.lookAt = _params.lookAt
end

----------------------------------------------------------------------
-- ChargeCommand: Commands a bot to attack a specified position at a running pace. This is faster than Attack but incurs an additional firing delay penalty.

ChargeCommand = class(Command)

-- @param botId The bot being ordered.
-- @param target The target location that the bot will charge to.
-- @param description A description of the intention of the bot. This can be optional displayed in the gui next to the bot label.
function ChargeCommand:new(_botId, _params, _description)
	Command.new(self, _botId, _description)
	if _params.target then
		self.target = { _params.target }
	elseif _params.target_list then
		self.target = {}
		for _, target in ipairs(_params.target_list) do
			table.insert(self.target_list, target)
		end
	else
		error("MoveCommand has no target given")
	end
end
