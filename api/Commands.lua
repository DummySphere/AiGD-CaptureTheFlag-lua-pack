
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

-- @param botId The bot being ordered.
-- @param facingDirection The facing direction of the bot.
-- @param description A description of the intention of the bot. This can be optional displayed in the gui next to the bot label.
function DefendCommand:new(_botId, _params, _description)
	Command.new(self, _botId, _description)
	assert(_params.facingDirection ~= nil)
	self.facingDirection = _params.facingDirection
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
