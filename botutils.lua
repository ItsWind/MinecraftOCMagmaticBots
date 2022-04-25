local botutils = {}
local robot = require("robot")
local computer = require("computer")
local component = require("component")

local nav = component.navigation

local configVars = require("config")
function botutils.getConfig(str)
  return configVars[str]
end

local facingNums = {
  ["n"] = 2,
  ["e"] = 5,
  ["s"] = 3,
  ["w"] = 4
}
function botutils.faceNum(facingNum)
  while component.navigation.getFacing() ~= facingNum do robot.turnRight() end
end
function botutils.face(facingStr)
  botutils.faceNum(facingNums[facingStr])
end

function botutils.multipleMove(moveFunc, times)
  while times > 0 do
    if moveFunc() then
      times = times-1
    end
  end
end

function botutils.say(str)
  os.execute("clear")
  print(str)
end

return botutils