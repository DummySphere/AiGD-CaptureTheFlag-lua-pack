
require "class"

----------------------------------------------------------------------
-- ConnectServer

ConnectServer = class()

ConnectServer.expectedProtocolVersion = "1.2"

function ConnectServer:new(_protocolVersion)
    self.protocolVersion = _protocolVersion
end

function ConnectServer:validate()
	if self.protocolVersion ~= self.expectedProtocolVersion then
		error("This client version does not match network protocol version. Expected version %s received %s.\n", self.expectedProtocolVersion, self.protocolVersion)
		return false
	end
	return true
end

----------------------------------------------------------------------
-- ConnectClient

ConnectClient = class()

function ConnectClient:new(_commanderName, _language)
    self.commanderName = _commanderName
    self.language = _language
end
