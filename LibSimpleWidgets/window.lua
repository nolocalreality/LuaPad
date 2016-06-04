local function AddDragEventsToBorder(window)
  local border = window:GetBorder()
  function border.Event:LeftDown()
    self.leftDown = true
    local mouse = Inspect.Mouse()
    self.originalXDiff = mouse.x - self:GetLeft()
    self.originalYDiff = mouse.y - self:GetTop()
  end
  function border.Event:LeftUp()
    self.leftDown = false
  end
  function border.Event:LeftUpoutside()
    self.leftDown = false
  end
  function border.Event:MouseMove(x, y)
    if not self.leftDown then
      return
    end
    window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
  end
end

local function AddDragFrame(window)
  window.dragWindow = UI.CreateFrame("Frame", window:GetName().."Drag", window:GetBorder())
  window.dragWindow:SetAllPoints(window)
  function window.dragWindow.Event:LeftDown()
    self.leftDown = true
    local mouse = Inspect.Mouse()
    self.originalXDiff = mouse.x - self:GetLeft()
    self.originalYDiff = mouse.y - self:GetTop()
  end

  function window.dragWindow.Event:LeftUp()
    self.leftDown = false
  end

  function window.dragWindow.Event:LeftUpoutside()
    self.leftDown = false
  end

  function window.dragWindow.Event:MouseMove(x, y)
    if not self.leftDown then
      return
    end
    window:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x - self.originalXDiff, y - self.originalYDiff)
  end
end

function Library.LibSimpleWidgets.Window(name, parent)
  local window = UI.CreateFrame("RiftWindow", name, parent)
  if not pcall(AddDragEventsToBorder, window) then
    AddDragFrame(window)
  end
  return window
end
