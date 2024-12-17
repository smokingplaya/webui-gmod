--- React GMOD
---
--- React GMOD is a library for the game Garry's Mod
--- that allows you to conveniently develop web-based interfaces.
---
--- Created by smokingplaya @ 2024-2025
--- Distributed under the GNU GPLv3

--- Config
-- ? Should we check version of react-gmod or not
local versionValidatorEnabled = true

--- Constants
local VERSION = "1.0.2"
local ADDON_JSON = "https://raw.githubusercontent.com/smokingplaya/react-gmod/refs/heads/main/addon.json"

--- Logs
local logColor = Color(0, 255, 255)
local whitespace = " "

local log = function(...)
  MsgC(logColor, "[react-gmod]", whitespace, color_white, ...)
  MsgN()
end

--- addon.json getter
local getAddonData = function(onSuccess, onFailure)
  http.Fetch(
    ADDON_JSON,
    function(body, _, _, code)
      if (code != 200) then
        return onFailure("HTTP Code " .. code)
      end

      onSuccess(util.JSONToTable(body))
    end,
    function(message)
      log("Unable to load react-gmod's data due to:", message)
      onFailure(message)
    end
  )
end

--- Version Validator
local getVersion = function(onSuccess, onFailure)
  getAddonData(function(data)
    onSuccess(data.version)
  end, onFailure)
end

local splitVersion = function(version)
  local parts = {}

  for part in string.gmatch(version, "(%d+)") do
    parts[#parts+1] = tonumber(part)
  end

  return parts
end

local isOutdated = function(currentVersion)
  local v1 = splitVersion(VERSION)
  local v2 = splitVersion(currentVersion)

  for i = 1, math.max(#v1, #v2) do
    local part1 = v1[i] or 0
    local part2 = v2[i] or 0
    if part1 < part2 then
      return true
    elseif part1 > part2 then
      return false
    end
  end

  return false -- версии равны
end

local validateVersion = function(onSuccess)
  if (!versionValidatorEnabled) then
    return onSuccess()
  end

  getVersion(function(version)
    if (isOutdated(version)) then
      return log(("You're on an outdated version! Your %s, new %s"):format(VERSION, version))
    end

    onSuccess()
  end, function(error)
    log("Version check error: " .. error)
    log("Version check failed, react-gmod will not be enabled.")
  end)
end

--- Addon load
if (SERVER) then
  validateVersion(function()
    log(("React GMod %s by smokingplaya<3"):format(VERSION))
    log("\thttps://github.com/smokingplaya/react-gmod")
  end)
end