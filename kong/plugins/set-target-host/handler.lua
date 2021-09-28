local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.set-target-host.access"
local SetTargetHostHandler = BasePlugin:extend()

SetTargetHostHandler.PRIORITY = 805
SetTargetHostHandler.VERSION = "1.0.0"

function SetTargetHostHandler:new()
  SetTargetHostHandler.super.new(self, "set-target-host")
end

function SetTargetHostHandler:access(conf)
  SetTargetHostHandler.super.access(self)
  access.execute(conf)
end

return SetTargetHostHandler
