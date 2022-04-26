local robot = require("robot")
local computer = require("computer")
local component = require("component")
local botutils = require("botutils")

local invController = component.inventory_controller
local tankController = component.tank_controller
local nav = component.navigation

local args = {...}
local smelteryTankCapacity = 25889
local smelteryTankLevel = args[1]

local function fillUp()
  botutils.face("s")
  smelteryTankLevel = smelteryTankLevel - robot.tankSpace()
  robot.useUp()
  while robot.tankSpace() ~= 0 do os.sleep(5) end
end

local function grabPyrotheum()
  botutils.face("w")
  local pyrotheumAmtToGrab = math.floor((smelteryTankCapacity - smelteryTankLevel)/100)
  local currentChestSlot = 1
  while pyrotheumAmtToGrab > 0 do
    if currentChestSlot > invController.getInventorySize(3) then break end
    local pyrotheumAmtInSelectedSlot = invController.getStackInSlot(3, currentChestSlot)["size"]
    if pyrotheumAmtInSelectedSlot > pyrotheumAmtToGrab then pyrotheumAmtInSelectedSlot = pyrotheumAmtToGrab end
    invController.suckFromSlot(3, currentChestSlot, pyrotheumAmtInSelectedSlot)
    pyrotheumAmtToGrab = pyrotheumAmtToGrab - pyrotheumAmtInSelectedSlot
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
  robot.select(1)
end

local function doMagmaticRow(useLeft, rowNum)
  local turnFuncToUse = { [true] = robot.turnLeft, [false] = robot.turnRight }
  local magsDone = 0
  local magsToDo = botutils.getConfig("magmaticColumns")
  repeat
    local fillAmt = tankController.getTankCapacity(3) - tankController.getTankLevel(3)
    robot.fill(fillAmt)
    magsDone = magsDone + 1
    if magsDone < magsToDo then
      turnFuncToUse[useLeft]()
      botutils.multipleMove(robot.forward, 1)
      turnFuncToUse[not useLeft]()
    end
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
    os.sleep(botutils.getConfig("restTimeInSeconds"))
  end
end

main()