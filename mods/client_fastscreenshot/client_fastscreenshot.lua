fastScreenshotButton = nil

local fastScreenshotDirName = "/fast_screenshots"
local fastScreenshotDir = g_resources.getWriteDir()..fastScreenshotDirName


function init()
  fastScreenshotButton = modules.client_topmenu.addLeftButton('fastScreenshotButton', tr('Fast Screenshot'), '/client_fastscreenshot/img_client_fastscreenshot/fastScreenshot_icon', makeScreenshot)

  if not g_resources.directoryExists(fastScreenshotDir) then
    g_resources.makeDir(fastScreenshotDirName)
  end
end

function terminate()
  fastScreenshotButton:destroy()
end

-------------------------------------------------
--Scripts----------------------------------------
-------------------------------------------------

local counter = 0

function makeScreenshot()
  local screenshotName = os.date("%Y%m%d%H%M%S").."_"..counter..".png"
  counter = counter + 1

  g_window.makeScreenShot(fastScreenshotDirName.."/"..screenshotName)
  addAlertToScreenshot()
end

function addAlertToScreenshot()
  fastScreenshotButton:setOn(true)
  scheduleEvent(function()
    fastScreenshotButton:setOn(false)
  end, 500)
end