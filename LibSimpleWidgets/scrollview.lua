-- Scrollview class

local function SetContent(self, content)
  if self.content then
    self.content:SetVisible(false)
    self.content.Event.Size = self.oldContentSizeFunc
    self.oldContentSizeFunc = nil
    self.content = nil
  end

  self.content = content

  content:SetParent(self)
  content:SetLayer(5)

  self.oldContentSizeFunc = content.Event.Size
  function content.Event:Size()
    content:GetParent():ContentResized()
    if content:GetParent().oldContentSizeFunc then
      content:GetParent():oldContentSizeFunc()
    end
  end

  self.offset = 0

  self:ContentResized()
end

local function GetScrollInterval(self)
  return self.scrollInterval
end

local function SetScrollInterval(self, interval)
  self.scrollInterval = interval
end

local function GetShowScrollbar(self)
  return self.showScrollbar
end

local function SetShowScrollbar(self, show)
  self.showScrollbar = show
  self.scrollbar:SetVisible(show)
end

local function GetScrollbarColor(self)
  return self.scrollbar:GetBackgroundColor()
end

local function SetScrollbarColor(self, r, g, b, a)
  self.scrollbar:SetBackgroundColor(r, g, b, a)
end

local function GetScrollbarWidth(self)
  return self.scrollbar:GetWidth()
end

local function SetScrollbarWidth(self, width)
  self.scrollbar:SetWidth(width)
end

local function GetMaxOffset(self)
  return self.content:GetHeight() - self:GetHeight()
end

local function GetOffsetForScrollbarY(self, y)
  return y / self:GetHeight() * self.content:GetHeight()
end

local function ContentResized(self)
  if self.content:GetHeight() < self:GetHeight() then
    self.scrollbar:SetVisible(false)
    self.offset = 0
  else
    local maxOffset = self:GetMaxOffset()
    if self.offset > maxOffset then
      self.offset = maxOffset
    end
    self.scrollbar:SetHeight(self:GetHeight() / self.content:GetHeight() * self:GetHeight())
    self.scrollbar:SetVisible(self.showScrollbar)
  end
  self:PositionContent()
  self:PositionScrollbar()
end

local function PositionContent(self)
  self.content:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -self.offset)
  self.content:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -self.offset)
end

local function PositionScrollbar(self)
  local scrollbarOffset = self.offset / self.content:GetHeight() * self:GetHeight()
  self.scrollbar:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, scrollbarOffset)
end

local function WheelForward(self)
  if not self.content then
    return
  end

  if self.content:GetHeight() < self:GetHeight() then
    return
  end

  if self.offset >= self.scrollInterval then
    self.offset = self.offset - self.scrollInterval
  else
    self.offset = 0
  end

  self:PositionContent()
  self:PositionScrollbar()
end

local function WheelBack(self)
  if not self.content then
    return
  end

  if self.content:GetHeight() < self:GetHeight() then
    return
  end

  local maxOffset = self:GetMaxOffset()
  if self.offset <= maxOffset - self.scrollInterval then
    self.offset = self.offset + self.scrollInterval
  else
    self.offset = maxOffset
  end

  self:PositionContent()
  self:PositionScrollbar()
end

local function CreateScrollbar(scrollview)
  local scrollbar = UI.CreateFrame("Frame", scrollview:GetName().."Scrollbar", scrollview:GetParent())
  scrollbar.scrollview = scrollview
  scrollbar:SetLayer(10)
  scrollbar:SetWidth(10)
  scrollbar:SetBackgroundColor(1, 1, 1, 0.5)
  scrollbar:SetPoint("TOPRIGHT", scrollview, "TOPRIGHT", 0, 0)
  scrollbar:SetVisible(false)
  scrollbar.leftDown = false
  function scrollbar.Event:LeftDown()
    self.leftDown = true
    self.originalYDiff = Inspect.Mouse().y - self:GetTop()
  end
  function scrollbar.Event:LeftUp()
    self.leftDown = false
  end
  function scrollbar.Event:LeftUpoutside()
    self.leftDown = false
  end
  function scrollbar.Event:MouseMove(x, y)
    if not self.leftDown then
      return
    end

    local view = self.scrollview

    local relY = y - view:GetTop()
    local newScrollY = relY - self.originalYDiff
    view.offset = math.min(view:GetMaxOffset(), math.max(0, view:GetOffsetForScrollbarY(newScrollY)))

    view:PositionContent()
    view:PositionScrollbar()
  end
  return scrollbar
end

function Library.LibSimpleWidgets.ScrollView(name, parent)
  local view = UI.CreateFrame("Mask", name, parent)
  view.bg = UI.CreateFrame("Frame", view:GetName().."BG", view)
  view.bg:SetAllPoints(view)
  view.bg:SetLayer(-1)
  view.bg:SetBackgroundColor(0, 0, 0, 0)

  view.SetContent = SetContent
  view.GetScrollInterval = GetScrollInterval
  view.SetScrollInterval = SetScrollInterval
  view.GetShowScrollbar = GetShowScrollbar
  view.SetShowScrollbar = SetShowScrollbar
  view.GetScrollbarColor = GetScrollbarColor
  view.SetScrollbarColor = SetScrollbarColor
  view.GetScrollbarWidth = GetScrollbarWidth
  view.SetScrollbarWidth = SetScrollbarWidth
  function view:SetBorder(width, r, g, b, a)
    Library.LibSimpleWidgets.SetBorder(self, width, r, g, b, a)
  end
  function view:SetBackgroundColor(r, g, b, a)
    self.bg:SetBackgroundColor(r, g, b, a)
  end
  view.GetMaxOffset = GetMaxOffset
  view.GetOffsetForScrollbarY = GetOffsetForScrollbarY
  view.ContentResized = ContentResized
  view.PositionContent = PositionContent
  view.PositionScrollbar = PositionScrollbar
  view.Event.WheelBack = WheelBack
  view.Event.WheelForward = WheelForward

  view.scrollbar = CreateScrollbar(view)

  view.scrollInterval = 35
  view.showScrollbar = true

  return view
end
