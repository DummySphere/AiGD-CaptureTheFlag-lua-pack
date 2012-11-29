
----------------------------------------------------------------------
-- JSON base

JSON = { null = {}, codec = {} }

function JSON.register(_class, _name, _object_to_table, _table_to_object)
	local codec = { class = _class, name = _name, serialize = _object_to_table, unserialize = _table_to_object }
	JSON.codec[_class] = codec
	JSON.codec[_name] = codec
end

function JSON.object_to_table(_name_or_class, _object, ...)
	local codec = JSON.codec[_name_or_class]
	assert(codec ~= nil)
	return { __class__ = codec.name, __value__ = codec.serialize(_object, ...) }
end
function JSON.table_to_object(_name_or_class, _table, ...)
	local codec = JSON.codec[_name_or_class]
	assert(codec ~= nil)
	assert(_table.__class__ == codec.name)
	assert(type(_table.__value__) == "table")
	return codec.unserialize(_table.__value__, ...)
end
function JSON.parse_map(_func, _name_or_class, _map, ...)
	local new_map = {}
	for key, value in pairs(_map) do
		new_map[key] = _func(_name_or_class, value, ...)
	end
	return new_map
end

function JSON.table_to_json(_table)
	local table_len = #_table
	local table_type = "array"
	for key, value in pairs(_table) do
		if type(key) ~= "number" or math.floor(key) ~= key or key > table_len then
			table_type = "object"
			break
		end
	end
	
	local function value_to_json(_value)
		if _value == JSON.null then
			return "null"
		else
			local value_type = type(_value)
			if value_type == "table" then
				return JSON.table_to_json(_value)
			elseif value_type == "number" or value_type == "boolean" then
				return tostring(_value)
			else
				return string.format("%q", tostring(_value))
			end
		end
	end
	local json
	if table_type == "array" then
		json = "["
		local first = true
		for _, value in ipairs(_table) do
			if first then
				first = false
			else
				json = json .. ", "
			end
			json = json .. value_to_json(value)
		end
		json = json .. "]"
	else
		json = "{"
		local first = true
		for key, value in pairs(_table) do
			if first then
				first = false
			else
				json = json .. ", "
			end
			json = json .. string.format("%q: ", key) .. value_to_json(value)
		end
		json = json .. "}"
	end
	
	-- print(json)
	return json
end
-- local lua_table = {["__class__"] = "GameInfo", ["__value__"] = {["teams"] = {["Blue"] = {["__class__"] = "TeamInfo", ["__value__"] = {["flagScoreLocation"] = {82.0, 20.0}, ["name"] = "Blue", ["flagSpawnLocation"] = {82.0, 20.0}, ["flag"] = "BlueFlag", ["members"] = {"Blue0", "Blue1", "Blue2", "Blue3", "Blue4"}, ["botSpawnArea"] = {{79.0, 2.0}, {85.0, 9.0}}}}, ["Red"] = {["__class__"] = "TeamInfo", ["__value__"] = {["flagScoreLocation"] = {6.0, 30.0}, ["name"] = "Red", ["flagSpawnLocation"] = {6.0, 30.0}, ["flag"] = "RedFlag", ["members"] = {"Red0", "Red1", "Red2", "Red3", "Red4"}, ["botSpawnArea"] = {{3.0, 41.0}, {9.0, 48.0}}}}}, ["flags"] = {["BlueFlag"] = {["__class__"] = "FlagInfo", ["__value__"] = {["position"] = {82.0, 20.0}, ["carrier"] = null, ["name"] = "BlueFlag", ["respawnTimer"] = -7.450580596923828e-09, ["team"] = "Blue"}}, ["RedFlag"] = {["__class__"] = "FlagInfo", ["__value__"] = {["position"] = {9.723822593688965, 28.638526916503906}, ["carrier"] = "Blue1", ["name"] = "RedFlag", ["respawnTimer"] = -7.450580596923828e-09, ["team"] = "Red"}}}, ["enemyTeam"] = "Red", ["team"] = "Blue", ["bots"] = {["Red3"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Red3", ["facingDirection"] = {0.9375345706939697, -0.3478919267654419}, ["state"] = 6, ["health"] = 0, ["seenlast"] = 13.370665550231934, ["team"] = "Red", ["currentAction"] = "ShootAtCommand", ["position"] = {35.6309928894043, 26.81215476989746}, ["visibleEnemies"] = {}}}, ["Red2"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {"Blue0"}, ["flag"] = null, ["name"] = "Red2", ["facingDirection"] = {0.9123391509056091, -0.4094350337982178}, ["state"] = 6, ["health"] = 0, ["seenlast"] = 0.0, ["team"] = "Red", ["currentAction"] = "ShootAtCommand", ["position"] = {68.28890991210938, 25.360763549804688}, ["visibleEnemies"] = {}}}, ["Red1"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {"Blue0"}, ["flag"] = null, ["name"] = "Red1", ["facingDirection"] = {-0.9972056150436401, 0.07470673322677612}, ["state"] = 4, ["health"] = 0, ["seenlast"] = 0.0, ["team"] = "Red", ["currentAction"] = "AttackCommand", ["position"] = {68.53483581542969, 25.27260398864746}, ["visibleEnemies"] = {}}}, ["Red0"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Red0", ["facingDirection"] = {0.9994280338287354, -0.033820152282714844}, ["state"] = 6, ["health"] = 0, ["seenlast"] = 13.370665550231934, ["team"] = "Red", ["currentAction"] = "ShootAtCommand", ["position"] = {34.46906280517578, 24.155515670776367}, ["visibleEnemies"] = {}}}, ["Red4"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {"Blue0"}, ["flag"] = null, ["name"] = "Red4", ["facingDirection"] = {0.912505030632019, -0.4090656042098999}, ["state"] = 6, ["health"] = 0, ["seenlast"] = 0.0, ["team"] = "Red", ["currentAction"] = "ShootAtCommand", ["position"] = {68.30572509765625, 25.36515998840332}, ["visibleEnemies"] = {}}}, ["Blue1"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = "RedFlag", ["name"] = "Blue1", ["facingDirection"] = {0.9242773652076721, -0.3817223310470581}, ["state"] = 3, ["health"] = 100.0, ["seenlast"] = null, ["team"] = "Blue", ["currentAction"] = "MoveCommand", ["position"] = {9.723822593688965, 28.638526916503906}, ["visibleEnemies"] = {}}}, ["Blue0"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Blue0", ["facingDirection"] = {-0.9890086054801941, 0.14785832166671753}, ["state"] = 1, ["health"] = 100.0, ["seenlast"] = null, ["team"] = "Blue", ["currentAction"] = null, ["position"] = {81.625, 19.375}, ["visibleEnemies"] = {"Red2", "Red1", "Red4"}}}, ["Blue3"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Blue3", ["facingDirection"] = {-0.9994280338287354, 0.03381979465484619}, ["state"] = 1, ["health"] = 0, ["seenlast"] = null, ["team"] = "Blue", ["currentAction"] = null, ["position"] = {48.790069580078125, 23.665205001831055}, ["visibleEnemies"] = {}}}, ["Blue2"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Blue2", ["facingDirection"] = {-0.9112738966941833, 0.411800742149353}, ["state"] = 6, ["health"] = 0, ["seenlast"] = null, ["team"] = "Blue", ["currentAction"] = "ShootAtCommand", ["position"] = {57.94633102416992, 32.63374710083008}, ["visibleEnemies"] = {}}}, ["Blue4"] = {["__class__"] = "BotInfo", ["__value__"] = {["seenBy"] = {}, ["flag"] = null, ["name"] = "Blue4", ["facingDirection"] = {-0.9575538635253906, 0.2882544994354248}, ["state"] = 6, ["health"] = 0, ["seenlast"] = null, ["team"] = "Blue", ["currentAction"] = "ShootAtCommand", ["position"] = {47.545501708984375, 19.977867126464844}, ["visibleEnemies"] = {}}}}, ["match"] = {["__class__"] = "MatchInfo", ["__value__"] = {["timeRemaining"] = 148.42462158203125, ["timeToNextRespawn"] = 13.427755355834961, ["combatEvents"] = {{["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue3", ["time"] = 14.939663887023926, ["type"] = 1, ["subject"] = "Red3"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Red2", ["time"] = 16.550338745117188, ["type"] = 1, ["subject"] = "Blue2"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Red4", ["time"] = 16.550338745117188, ["type"] = 1, ["subject"] = "Blue2"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Red0", ["time"] = 17.310344696044922, ["type"] = 1, ["subject"] = "Blue4"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue3", ["time"] = 18.036685943603516, ["type"] = 1, ["subject"] = "Red0"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Red1", ["time"] = 18.201021194458008, ["type"] = 1, ["subject"] = "Blue3"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue0", ["time"] = 28.15752601623535, ["type"] = 1, ["subject"] = "Red4"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue1", ["time"] = 28.15752601623535, ["type"] = 2, ["subject"] = "RedFlag"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue0", ["time"] = 28.616199493408203, ["type"] = 1, ["subject"] = "Red2"}}, {["__class__"] = "MatchCombatEvent", ["__value__"] = {["instigator"] = "Blue0", ["time"] = 29.308876037597656, ["type"] = 1, ["subject"] = "Red1"}}}, ["timePassed"] = 31.5719051361084, ["scores"] = {["Blue"] = 0, ["Red"] = 0}}}}}
-- local t = JSON.table_to_json(lua_table)
function JSON.json_to_table(_json)
	local lua_code = _json
	-- print(lua_code)
	
	local count = nil
	repeat
		lua_code, count = string.gsub(lua_code, "([%[%:%,%{]%s*)(%[)", "%1{")
	until count == 0
	-- print(lua_code)
	
	local count = nil
	repeat
		lua_code, count = string.gsub(lua_code, "(%])(%s*[%]%,%}])", "}%2")
	until count == 0
	-- print(lua_code)
	
	lua_code = string.gsub(lua_code, '(%"[%w%_]+%")%s*(%:)', "[%1] =")
	-- print(lua_code)
	
	lua_code = string.gsub(lua_code, '%=%s*null', "= nil")
	-- print(lua_code)
	
	local chunk = loadstring("return " .. lua_code, "input json")
	if not chunk then
		error("cannot convert json to lua ...\njson: " .. _table .. "\nlua: " .. lua_code)
	end
	
	return chunk()
end
-- local json = [=[{"__class__": "GameInfo", "__value__": {"teams": {"Blue": {"__class__": "TeamInfo", "__value__": {"flagScoreLocation": [82.0, 20.0], "name": "Blue", "flagSpawnLocation": [82.0, 20.0], "flag": "BlueFlag", "members": ["Blue0", "Blue1", "Blue2", "Blue3", "Blue4"], "botSpawnArea": [[79.0, 2.0], [85.0, 9.0]]}}, "Red": {"__class__": "TeamInfo", "__value__": {"flagScoreLocation": [6.0, 30.0], "name": "Red", "flagSpawnLocation": [6.0, 30.0], "flag": "RedFlag", "members": ["Red0", "Red1", "Red2", "Red3", "Red4"], "botSpawnArea": [[3.0, 41.0], [9.0, 48.0]]}}}, "flags": {"BlueFlag": {"__class__": "FlagInfo", "__value__": {"position": [82.0, 20.0], "carrier": null, "name": "BlueFlag", "respawnTimer": -7.450580596923828e-09, "team": "Blue"}}, "RedFlag": {"__class__": "FlagInfo", "__value__": {"position": [9.723822593688965, 28.638526916503906], "carrier": "Blue1", "name": "RedFlag", "respawnTimer": -7.450580596923828e-09, "team": "Red"}}}, "enemyTeam": "Red", "team": "Blue", "bots": {"Red3": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Red3", "facingDirection": [0.9375345706939697, -0.3478919267654419], "state": 6, "health": 0, "seenlast": 13.370665550231934, "team": "Red", "currentAction": "ShootAtCommand", "position": [35.6309928894043, 26.81215476989746], "visibleEnemies": []}}, "Red2": {"__class__": "BotInfo", "__value__": {"seenBy": ["Blue0"], "flag": null, "name": "Red2", "facingDirection": [0.9123391509056091, -0.4094350337982178], "state": 6, "health": 0, "seenlast": 0.0, "team": "Red", "currentAction": "ShootAtCommand", "position": [68.28890991210938, 25.360763549804688], "visibleEnemies": []}}, "Red1": {"__class__": "BotInfo", "__value__": {"seenBy": ["Blue0"], "flag": null, "name": "Red1", "facingDirection": [-0.9972056150436401, 0.07470673322677612], "state": 4, "health": 0, "seenlast": 0.0, "team": "Red", "currentAction": "AttackCommand", "position": [68.53483581542969, 25.27260398864746], "visibleEnemies": []}}, "Red0": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Red0", "facingDirection": [0.9994280338287354, -0.033820152282714844], "state": 6, "health": 0, "seenlast": 13.370665550231934, "team": "Red", "currentAction": "ShootAtCommand", "position": [34.46906280517578, 24.155515670776367], "visibleEnemies": []}}, "Red4": {"__class__": "BotInfo", "__value__": {"seenBy": ["Blue0"], "flag": null, "name": "Red4", "facingDirection": [0.912505030632019, -0.4090656042098999], "state": 6, "health": 0, "seenlast": 0.0, "team": "Red", "currentAction": "ShootAtCommand", "position": [68.30572509765625, 25.36515998840332], "visibleEnemies": []}}, "Blue1": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": "RedFlag", "name": "Blue1", "facingDirection": [0.9242773652076721, -0.3817223310470581], "state": 3, "health": 100.0, "seenlast": null, "team": "Blue", "currentAction": "MoveCommand", "position": [9.723822593688965, 28.638526916503906], "visibleEnemies": []}}, "Blue0": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Blue0", "facingDirection": [-0.9890086054801941, 0.14785832166671753], "state": 1, "health": 100.0, "seenlast": null, "team": "Blue", "currentAction": null, "position": [81.625, 19.375], "visibleEnemies": ["Red2", "Red1", "Red4"]}}, "Blue3": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Blue3", "facingDirection": [-0.9994280338287354, 0.03381979465484619], "state": 1, "health": 0, "seenlast": null, "team": "Blue", "currentAction": null, "position": [48.790069580078125, 23.665205001831055], "visibleEnemies": []}}, "Blue2": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Blue2", "facingDirection": [-0.9112738966941833, 0.411800742149353], "state": 6, "health": 0, "seenlast": null, "team": "Blue", "currentAction": "ShootAtCommand", "position": [57.94633102416992, 32.63374710083008], "visibleEnemies": []}}, "Blue4": {"__class__": "BotInfo", "__value__": {"seenBy": [], "flag": null, "name": "Blue4", "facingDirection": [-0.9575538635253906, 0.2882544994354248], "state": 6, "health": 0, "seenlast": null, "team": "Blue", "currentAction": "ShootAtCommand", "position": [47.545501708984375, 19.977867126464844], "visibleEnemies": []}}}, "match": {"__class__": "MatchInfo", "__value__": {"timeRemaining": 148.42462158203125, "timeToNextRespawn": 13.427755355834961, "combatEvents": [{"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue3", "time": 14.939663887023926, "type": 1, "subject": "Red3"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Red2", "time": 16.550338745117188, "type": 1, "subject": "Blue2"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Red4", "time": 16.550338745117188, "type": 1, "subject": "Blue2"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Red0", "time": 17.310344696044922, "type": 1, "subject": "Blue4"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue3", "time": 18.036685943603516, "type": 1, "subject": "Red0"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Red1", "time": 18.201021194458008, "type": 1, "subject": "Blue3"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue0", "time": 28.15752601623535, "type": 1, "subject": "Red4"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue1", "time": 28.15752601623535, "type": 2, "subject": "RedFlag"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue0", "time": 28.616199493408203, "type": 1, "subject": "Red2"}}, {"__class__": "MatchCombatEvent", "__value__": {"instigator": "Blue0", "time": 29.308876037597656, "type": 1, "subject": "Red1"}}], "timePassed": 31.5719051361084, "scores": {"Blue": 0, "Red": 0}}}}}]=]
-- local t = JSON.json_to_table(json)

function JSON.encode(_name_or_class, _object, ...)
	return JSON.table_to_json(JSON.object_to_table(_name_or_class, _object, ...))
end
function JSON.decode(_name_or_class, _json, ...)
	return JSON.table_to_object(_name_or_class, JSON.json_to_table(_json), ...)
end

----------------------------------------------------------------------
-- Handshaking

require "Handshaking"
JSON.register(
		ConnectServer,
		"ConnectServer",
		function(_object)
			return {
				protocolVersion = _object.protocolVersion,
			}
		end,
		function(_table)
			return ConnectServer(_table.protocolVersion)
		end
	)
JSON.register(
		ConnectClient,
		"ConnectClient",
		function(_object)
			return {
				language = _object.language,
				commanderName = _object.commanderName,
			}
		end,
		function(_table)
			return ConnectClient(_table.language, _table.commanderName)
		end
	)

----------------------------------------------------------------------
-- GameInfo

require "GameInfo"
JSON.register(
		LevelInfo,
		"LevelInfo",
		function(_object)
			return {
				width = _object.width,
				height = _object.height,
				blockHeights = _object.blockHeights,
				teamNames = _object.teamNames,
				flagSpawnLocations = _object.flagSpawnLocations,
				flagScoreLocations = _object.flagScoreLocations,
				botSpawnAreas = _object.botSpawnAreas,
				FOVangle = _object.FOVangle,
				characterRadius = _object.characterRadius,
				walkingSpeed = _object.walkingSpeed,
				runningSpeed = _object.runningSpeed,
				firingDistance = _object.firingDistance,
				gameLength = _object.gameLength,
				initializationTime = _object.initializationTime,
			}
		end,
		function(_table)
			return LevelInfo{
				width = _table.width,
				height = _table.height,
				blockHeights = _table.blockHeights,
				teamNames = _table.teamNames,
				flagSpawnLocations = _table.flagSpawnLocations,
				flagScoreLocations = _table.flagScoreLocations,
				botSpawnAreas = _table.botSpawnAreas,
				FOVangle = _table.FOVangle,
				characterRadius = _table.characterRadius,
				walkingSpeed = _table.walkingSpeed,
				runningSpeed = _table.runningSpeed,
				firingDistance = _table.firingDistance,
				gameLength = _table.gameLength,
				initializationTime = _table.initializationTime,
			}
		end
	)
JSON.register(
		GameInfo,
		"GameInfo",
		function(_object)
			return {
				teams = JSON.parse_map(JSON.object_to_table, "TeamInfo", _object.teams),
				team = _object.team.name,
				enemyTeam = _object.enemyTeam.name,
				flags = JSON.parse_map(JSON.object_to_table, "FlagInfo", _object.flags),
				bots = JSON.parse_map(JSON.object_to_table, "BotInfo", _object.bots),
				match = JSON.object_to_table("MatchInfo", _object.match),
			}
		end,
		function(_table)
			local params = {}
			params.bots = JSON.parse_map(JSON.table_to_object, "BotInfo", _table.bots)
			params.teams = JSON.parse_map(JSON.table_to_object, "TeamInfo", _table.teams, params)
			params.team = assert(params.teams[_table.team])
			params.enemyTeam = assert(params.teams[_table.enemyTeam])
			params.flags = JSON.parse_map(JSON.table_to_object, "FlagInfo", _table.flags, params)
			for name, team in pairs(params.teams) do
				team.flag = params.flags[team.flag]
			end
			for name, bot in pairs(params.bots) do
				bot.team = params.teams[bot.team]
				bot.flag = params.flags[bot.flag]
				for index, name in ipairs(bot.visibleEnemies) do
					bot.visibleEnemies[index] = params.bots[name]
				end
				for index, name in ipairs(bot.seenBy) do
					bot.seenBy[index] = params.bots[name]
				end
			end
			params.match = JSON.table_to_object("MatchInfo", _table.match, params)
			return GameInfo(params)
		end
	)
JSON.register(
		TeamInfo,
		"TeamInfo",
		function(_object)
			return {
				name = _object.name,
				members = _object.members, -- TODO: array of names
				flag = _object.flag and _object.flag.name or JSON.null,
				flagSpawnLocation = _object.flagSpawnLocation,
				flagScoreLocation = _object.flagScoreLocation,
				botSpawnArea = _object.botSpawnArea,
			}
		end,
		function(_table, _params)
			local params = {
				name = _table.name,
				members = {},
				flag = _table.flag, -- temp name, will be replaced by flag object in GameInfo unserialization
				flagSpawnLocation = _table.flagSpawnLocation,
				flagScoreLocation = _table.flagScoreLocation,
				botSpawnArea = _table.botSpawnArea,
			}
			for _, bot in ipairs(_table.members) do
				table.insert(params.members, assert(_params.bots[bot]))
			end
			return TeamInfo(params)
		end
	)
JSON.register(
		FlagInfo,
		"FlagInfo",
		function(_object)
			return {
				name = _object.name,
				team = _object.team.name,
				position = _object.position,
				carrier = _object.carrier and _object.carrier.name or JSON.null,
				respawnTimer = _object.respawnTimer,
			}
		end,
		function(_table, _params)
			return FlagInfo{
				name = _table.name,
				team = assert(_params.teams[_table.team]),
				position = _table.position,
				carrier = _table.carrier and assert(_params.bots[_table.carrier], tostring(_table.carrier) .. "bot not found") or JSON.null,
				respawnTimer = _table.respawnTimer,
			}
		end
	)
JSON.register(
		BotInfo,
		"BotInfo",
		function(_object)
			return {
				name = _object.name,
				team = _object.team.name,
				health = _object.health,
				state = _object.state,
				position = _object.position,
				facingDirection = _object.facingDirection,
				seenlast = _object.seenlast,
				flag = _object.flag and _object.flag.name or JSON.null,
				visibleEnemies = _object.visibleEnemies, -- TODO: array of names
				seenBy = _object.seenBy, -- TODO: array of names
			}
		end,
		function(_table)
			return BotInfo{
				name = _table.name,
				team = _table.team, -- temp name, will be replaced by team object in GameInfo unserialization
				health = _table.health,
				state = _table.state,
				position = _table.position,
				facingDirection = _table.facingDirection,
				seenlast = _table.seenlast,
				flag = _table.flag, -- temp name, will be replaced by flag object in GameInfo unserialization
				visibleEnemies = _table.visibleEnemies, -- temp name list, will be replaced by bot objects in GameInfo unserialization
				seenBy = _table.seenBy, -- temp name list, will be replaced by bot objects in GameInfo unserialization
			}
		end
	)
JSON.register(
		MatchInfo,
		"MatchInfo",
		function(_object)
			return {
				timeRemaining = _object.timeRemaining,
				timeToNextRespawn = _object.timeToNextRespawn,
				combatEvents = JSON.parse_map(JSON.object_to_table, "MatchCombatEvent", _object.combatEvents),
			}
		end,
		function(_table, _params)
			return MatchInfo{
				timeRemaining = _table.timeRemaining,
				timeToNextRespawn = _table.timeToNextRespawn,
				combatEvents = JSON.parse_map(JSON.table_to_object, "MatchCombatEvent", _table.combatEvents, _params),
			}
		end
	)
JSON.register(
		MatchCombatEvent,
		"MatchCombatEvent",
		function(_object)
			return {
				type = _object.type,
				time = _object.time,
				instigator = _object.instigator and _object.instigator.name or JSON.null,
				subject = _object.subject.name,
			}
		end,
		function(_table, _params)
			local bot_subject = { [MatchCombatEvent.TYPE_KILLED] = true, [MatchCombatEvent.TYPE_RESPAWN] = true }
			local flag_subject = { [MatchCombatEvent.TYPE_FLAG_PICKEDUP] = true, [MatchCombatEvent.TYPE_FLAG_DROPPED] = true, [MatchCombatEvent.TYPE_FLAG_CAPTURED] = true, [MatchCombatEvent.TYPE_FLAG_RESTORED] = true }
			local params = {
				type = _table.type,
				time = _table.time,
				instigator = _table.instigator and _params.bots[_table.instigator] or JSON.null,
			}
			if bot_subject[_table.type] then
				params.subject = _params.bots[_table.subject]
			elseif flag_subject[_table.type] then
				params.subject = _params.flags[_table.subject]
			else
				error(string.format("unkinown subject type %d for MatchCombatEvent", _table.type))
			end
			return MatchCombatEvent(params)
		end
	)

----------------------------------------------------------------------
-- Commands

require "Commands"
JSON.register(
		DefendCommand,
		"Defend",
		function(_object)
			local facingDirections = _object.facingDirections and JSON.parse_map(function(_name_or_class, value) return { value.direction, value.time } end, DefendCommand.FacingDirection, _object.facingDirections) or JSON.null
			return {
				bot = _object.botId,
				facingDirections = facingDirections,
				description = _object.description,
			}
		end,
		function(_table)
			local facingDirection_list = _table.facingDirections and JSON.parse_map(function(_name_or_class, value) return DefendCommand.FacingDirection(unpack(value)) end, DefendCommand.FacingDirection, _table.facingDirections)
			return DefendCommand(_table.bot, { facingDirection_list = facingDirection_list }, _table.description)
		end
	)
JSON.register(
		MoveCommand,
		"Move",
		function(_object)
			return {
				bot = _object.botId,
				target = _object.target,
				description = _object.description,
			}
		end,
		function(_table)
			return MoveCommand(_table.bot, { target_list = _table.target }, _table.description)
		end
	)
JSON.register(
		AttackCommand,
		"Attack",
		function(_object)
			return {
				bot = _object.botId,
				target = _object.target,
				lookAt = _object.lookAt or JSON.null,
				description = _object.description,
			}
		end,
		function(_table)
			return AttackCommand(_table.bot, { target_list = _table.target, lookAt = _table.lookAt }, _table.description)
		end
	)
JSON.register(
		ChargeCommand,
		"Charge",
		function(_object)
			return {
				bot = _object.botId,
				target = _object.target,
				description = _object.description,
			}
		end,
		function(_table)
			return ChargeCommand(_table.bot, { target_list = _table.target }, _table.description)
		end
	)
