
require "class"

Commander = class()

-- Constructor
function Commander:new()
	self.level = {}
	self.game = {}
	
	self.commands = {}
end

function Commander:getLanguage()
	return "Lua"
end

function Commander:getName()
	error("commander name not set, please override the Commander:getName() function")
end

-- Override this function for your own bots.
-- Use this function to setup your bot before the game starts.
function Commander:initialize()
end

-- Override this function for your own bots.
-- Here you can access all the information in m_level (information about the level being played)
-- and m_game (information about the current game state).
-- You can send commands to your bots using the issue member function
function Commander:tick()
	error("commander tick not defined, please override the Commander:tick() function")
end

-- Override this function for your own bots.
-- Use this function to teardown your bot after the game is over.
function Commander:shutdown()
end

-- Issue a command for a single bot, with optional arguments depending on the command.
function Commander:issue(cmd)
	table.insert(self.commands, cmd)
end
