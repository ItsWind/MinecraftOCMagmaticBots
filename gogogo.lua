local robot = require("robot")
local computer = require("computer")
local component = require("component")
local botutils = require("botutils")

local invController = component.inventory_controller
local tankController = component.tank_controller
local nav = component.navigation

local function fillUp()
  botutils.face("s")
  robot.useUp()
  while robot.tankSpace() ~= 0 do os.sleep(5) end
end

local function grabPyrotheum()
  botutils.face("w")
  local currentChestSlot = 1
  while invController.getStackInInternalSlot(robot.inventorySize()) == nil do
    if currentChestSlot > invController.getInventorySize(3) then break end
    invController.suckFromSlot(3, currentChestSlot)
    currentChestSlot = currentChestSlot+1
  end
end

local function fillSmelterTank()
  botutils.face("e")
  local fillAmt = tankController.getTankCapacity(3) - tankController.getTankLevel(3)
  robot.fill(fillAmt)
end

local function fillSmelterChest()
  for i=1,robot.inventorySize() do
    robot.select(i)
    robot.dropDown()
  end
end

local function doMagmaticRow(useLeft, rowNum)
  local turnFuncToUse = { [true] = robot.turnLeft, [false] = robot.turnRight }
  local magsDone = 0
  local magsToDo = botutils.getConfig("magmaticColumns")
  repeat
    local fillAmt = tankController.getTankCapacity(3) - tankController.getTankLevel(3)
    robot.fill(fillAmt)
    if magsDone < magsToDo then
      turnFuncToUse[useLeft]()
      botutils.multipleMove(robot.forward, 1)
      turnFuncToUse[not useLeft]()
    end
    magsDone = magsDone + 1
  until(magsDone >= magsToDo)
  if rowNum < botutils.getConfig("magmaticRows") then
    botutils.multipleMove(robot.up, 1)
    doMagmaticRow(not useLeft, rowNum+1)
  else
    botutils.multipleMove(robot.down, rowNum-1)
  end
end

local function main()
  while true do
    fillUp()
    fillSmelterTank()
    grabPyrotheum()
    robot.turnRight()
    botutils.multipleMove(robot.forward, 1)
    robot.turnRight()
    botutils.multipleMove(robot.forward, 2)
    fillSmelterChest()
    robot.turnLeft()
    botutils.multipleMove(robot.forward, 5)
    robot.turnLeft()
    botutils.multipleMove(robot.forward, 2)
    doMagmaticRow(false, 1)
    robot.turnLeft()
    botutils.multipleMove(robot.forward, 6)
    os.sleep(eve.getConfig("restTimeInSeconds"))
  end
end

main()