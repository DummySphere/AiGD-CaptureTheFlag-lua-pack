
package.path = package.path .. ";./api/?.lua"
io.stdout:setvbuf("no")

-- main
local HOST = "localhost"
local PORT = "41041"
local commanderModule = "MyCommander"

local arg = { ... }
if #arg == 0 then
	-- OK, nothing to do
elseif #arg == 1 then
	commanderModule = arg[1]
else
	if #arg > 3 then
		error("Usage: client [<hostname> <port>] [<commander>]")
		return 1
	end
	
	HOST = arg[1]
	PORT = arg[2]
	if #arg == 3 then
		commanderModule = arg[3]
	end
end

-- Create commander
require "Commander"

local commanderClass = require(commanderModule)
local commander = commanderClass()
local commanderName = commander:getName()
print(string.format("Commander %s loaded.", commanderName))

-- Create socket
local socket = require("socket.core")
local s, err = socket.tcp()
if s == nil then
	error("cannot create a tcp socket: " .. err)
end

-- Connect socket
print(string.format("Trying to connect to %s:%d ...", HOST, PORT))
local connected, err = false
for i = 1, 100 do
	local ok
	ok, err = s:connect(HOST, PORT)
	if ok ~= nil then
		print(string.format("Connected to %s:%d", HOST, PORT))
		connected = ok
		break
	end
	
	print(string.format("... cannot connect to %s:%d (err = %s)", HOST, PORT, err))
	-- Try again within 10 ms
	socket.sleep(0.010)
end
if not connected then
	error(string.format("cannot connect to %s:%d: %s", HOST, PORT, err))
end

s:settimeout(0.005)
local buffer = ""
local function readline()
	local line, err, partial = s:receive("*l", partial)
	if line ~= nil then
		buffer = ""
		-- print(string.format("line received: %s", line))
		return line
	else
		if err == "closed" then
			error("connection closed")
		end
		if partial ~= buffer then
			print(string.format("partial line received: %s (err = %s)", partial, err))
		end
		buffer = partial
		return readline()
	end
end
local function writeline(_line)
	local count, err = s:send(_line .. "\n")
	if count ~= string.len(_line) + 1 then
		if count == nil and err == "closed" then
			error("connection closed")
		else
			error(string.format("Error sending data to server. %s", _line))
		end
	else
		-- print(string.format("line sent: %s", _line))
	end
end

-- socket.sleep(0.000010) -- 10 us

-- perform Handshaking

require "json"

local message = readline()
if message ~= "<connect>" then
	error(string.format("Expected connect message from the game server. Received %s", message))
end
local connectServerMessage = readline()
local connectServer = JSON.decode(ConnectServer, connectServerMessage)
if not connectServer:validate() then
	error("connectServer give wrong version")
end

local connectClient = ConnectClient(commanderName, commander:getLanguage())
local connectClientJson = JSON.encode(ConnectClient, connectClient)
writeline("<connect>")
writeline(connectClientJson)

-- initialize

local message = readline()
if message ~= "<initialize>" then
	error(string.format("Expected initialize message from the game server. Received %s", message))
end
local levelInfo = JSON.decode(LevelInfo, readline())
local gameInfo = JSON.decode(GameInfo, readline())
commander.level = levelInfo
commander.game = gameInfo
commander:initialize()
writeline("<ready>")

-- main loop

local shutdown = false
while not shutdown do
	local message = readline()
	if message == "<tick>" then
		local gameInfo = JSON.decode(GameInfo, readline())
		
		commander:tick()
		
        for _, command in ipairs(commander.commands) do
            local commandJson = JSON.encode(command:GetClass(), command)
			writeline("<command>")
			writeline(commandJson)
        end
        commander.commands = {}
	elseif message == "<shutdown>" then
		shutdown = true
	else
		error(string.format("Received unexpected message %s from server.", message))
	end
end

-- shutdown

commander:shutdown()
