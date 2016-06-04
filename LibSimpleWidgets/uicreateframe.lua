local frameConstructors = {
  SimpleList        = Library.LibSimpleWidgets.List,
  SimpleScrollView  = Library.LibSimpleWidgets.ScrollView,
  SimpleSelect      = Library.LibSimpleWidgets.Select,
  SimpleWindow      = Library.LibSimpleWidgets.Window,
}

local oldUICreateFrame = UI.CreateFrame
UI.CreateFrame = function(type, name, parent)
  local constructor = frameConstructors[type]
  if constructor then
    return constructor(name, parent)
  else
    return oldUICreateFrame(type, name, parent)
  end
end
