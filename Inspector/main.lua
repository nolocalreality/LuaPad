--[[
	Project: Inspector
	Version: 1.0.0
	Author: NerfedWar (http://www.nerfedwar.net - nerfed.war@gmail.com)
	
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
	
]] 

Inspector = {}

local context = UI.CreateContext("InspectorContext")

local helpWindow = UI.CreateFrame("SimpleWindow", "InspectorHelpWindow", context) 
local helpText = UI.CreateFrame("Text", "InspectorHelpText", helpWindow)
local helpCloseButton = UI.CreateFrame("RiftButton", "InspectorHelpCloseButton", helpWindow)
local helpIcon = UI.CreateFrame("Texture", "InspectorIcon", helpWindow)

local textWindow = UI.CreateFrame("SimpleWindow", "InspectorTextWindow", context) 
local textField = UI.CreateFrame("RiftTextfield", "InspectorTextField", textWindow)
local inputLabel = UI.CreateFrame("Text", "InspectorInputLabel", textWindow)
local inputField = UI.CreateFrame("RiftTextfield", "InspectorInputField", textWindow)
local depthLabel = UI.CreateFrame("Text", "InspectorDepthLabel", textWindow)
local depthText = UI.CreateFrame("Text", "InspectorDepthField", textWindow)
local depthSlider = UI.CreateFrame("RiftSlider", "InspectorSlider", textWindow)
local closeButton = UI.CreateFrame("RiftButton", "InspectorCloseButton", textWindow)
local inspectButton = UI.CreateFrame("RiftButton", "InspectorInspectButton", textWindow)
local helpButton = UI.CreateFrame("RiftButton", "InspectorHelpButton", textWindow)
	
	
-- Addon initialisation
local function init()

	textWindow:SetVisible(false)
	
	textWindow:SetWidth(800)
	textWindow:SetHeight(600)
	textWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
	textWindow:SetTitle("Inspector")
	textWindow:SetLayer(1)

	textField:SetWidth(750)
	textField:SetHeight(420)
	textField:SetPoint("TOPLEFT", textWindow, "TOPLEFT", 24, 60)
	textField:SetBackgroundColor(0,0,0,0.5)	
	textField:SetText("")
	
	inputLabel:SetWidth(70)
	inputLabel:SetHeight(18)
	inputLabel:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 24, -87)
	inputLabel:SetText("Variable/Table:")	
	
	inputField:SetWidth(670)
	inputField:SetHeight(18)	
	inputField:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 104, -87)
	inputField:SetBackgroundColor(0,0,0,0.8)
	inputField:SetText("")
	function inputField.Event:TextfieldChange()
		local a,b = depthText:GetText()
		Inspector.doInspection(inputField:GetText(), tonumber(a))
	end	
	
	depthLabel:SetWidth(70)
	depthLabel:SetHeight(18)
	depthLabel:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 64, -62)
	depthLabel:SetText("Depth:")	
	
	depthText:SetWidth(50)
	depthText:SetHeight(18)	
	depthText:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 104, -62)
	depthText:SetBackgroundColor(0,0,0,0.8)
	depthText:SetText("1")
	
	depthSlider:SetWidth(610)
	depthSlider:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 164, -54)
	depthSlider:SetRange(0,50)

	depthSlider:SetEnabled(true)
	function depthSlider.Event:SliderChange()
		depthText:SetText(tostring((50-depthSlider:GetPosition())))
		local a,b = depthText:GetText()
		Inspector.doInspection(inputField:GetText(), tonumber(a))
	end	
	depthSlider:SetPosition(49)	

	inspectButton:SetText("Inspect")
	inspectButton:SetPoint("BOTTOMLEFT", textWindow, "BOTTOMLEFT", 100, -20)	
	function inspectButton.Event:LeftPress()
		local a,b = depthText:GetText()	
		Inspector.doInspection(inputField:GetText(), tonumber(a))
	end	
	
	helpButton:SetText("Help")
	helpButton:SetPoint("BOTTOMCENTER", textWindow, "BOTTOMCENTER", 0, -20)	
	function helpButton.Event:LeftPress()
		helpWindow:SetVisible(true)
	end		
	
	closeButton:SetText("Close")
	closeButton:SetPoint("BOTTOMRIGHT", textWindow, "BOTTOMRIGHT", -100, -20)	
	function closeButton.Event:LeftPress()
		textWindow:SetVisible(false)
	end	
end


-- Configures the help window
local function initHelp()

		helpWindow:SetLayer(2)

	-- configure the help window
	helpWindow:SetVisible(false)
	helpWindow:SetWidth(800)
	helpWindow:SetHeight(600)
	helpWindow:SetTitle("Inspector Help")
	helpWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 300, 300)

	-- configure the help text
	helpText:SetWidth(800)
	helpText:SetHeight(600)
	helpText:SetPoint("TOPLEFT", helpWindow, "TOPLEFT", 20, 60)
	helpText:SetFontSize(14)
	helpText:SetText([[
			Inspector provides a quick way to inspect the contents of any LUA variable/table/function. 
	
Usage: 			
	Enter the name of the LUA variable/table/function you want to output and select the
	recursion depth (useful to set this to 1 if you just want ot see the top level
	structure of a LUA table.
	e.g.
		Inspect.Ability.List
			will display: Inspect.Ability.List = function: 0x0ed24bb8
		
		Inspect.Ability.List()
			will display: 
				Inspect.Ability.List().a000000000D674EA0 = true
				Inspect.Ability.List().a000000006F854A06 = true
				Inspect.Ability.List().a0000000006BDD965 = true
				Inspect.Ability.List().a000000002B3964A9 = true
				...

		Inspect.Ability.Detail('a000000000D674EA0')
			will display: 
				Inspect.Ability.Detail('a000000000D674EA0').costPower = 10
				Inspect.Ability.Detail('a000000000D674EA0').cooldown = 10.000000474975
				Inspect.Ability.Detail('a000000000D674EA0').icon = Data/\UI\ability_icons\void_knight-void_a.dds
				Inspect.Ability.Detail('a000000000D674EA0').name = Void
		
	Next Version:
		The next version will include the facility to monitor the values on one or more 
		variables/tables. As these variables/tables update, a new 'monitor' window
		will display the current values.

		NerfedWar
		http://www.nerfedwar.net
		nerfed.war@gmail.com 
	    
	]])
	
	-- create the icon
	helpIcon:SetWidth(64)
	helpIcon:SetHeight(64)
	helpIcon:SetPoint("BOTTOMLEFT", helpWindow, "BOTTOMLEFT", 12, -13)
	helpIcon:SetTexture("Inspector", "small_fangs.png")
	
	-- create the close button and add an event handler to hide the help window when it is presed
	helpCloseButton:SetText("Close")
	helpCloseButton:SetPoint("BOTTOMCENTER", helpWindow, "BOTTOMCENTER", 0, -20)
	function helpCloseButton.Event:LeftPress()
		helpWindow:SetVisible(false)
	end	

end

-- perform the recursive inspection
local temporaryTableDetails = {}
local function getTableDetails(obj, objName, targetDepth, previousDepth)
	local contents = ""
	local currentDepth = previousDepth + 1
	if type(obj) == "table" and (targetDepth == 0 or targetDepth >= currentDepth) then 
		if temporaryTableDetails[tostring(obj)] then
			return "Endless Loop detected on object ["..tostring(objName).."]\n"
		else
			temporaryTableDetails[tostring(obj)] = true
		end
		for k, a in pairs(obj) do
			contents = contents..getTableDetails(a, tostring(objName).."."..tostring(k), targetDepth, currentDepth)
		end
	else
		contents = tostring(objName).." = "
		if type(obj) == "wstring" then
			contents = contents.."\""..tostring(obj).."\"\n"
		else
			contents = contents..tostring(obj).."\n"
		end
	end
	temporaryTableDetails = {}
	return contents
end


-- display the inspection window
function Inspector.showInspectionWindow()
	textWindow:SetVisible(true)
end


-- perform the inspection and display the results
function Inspector.doInspection(obj, depth)

	-- check for nil, object concat and blank
	if( (obj == nil) or (obj == "") or (string.sub(obj, -1) == ".")) then
		return
	end
	
	-- check for unclosed brackets
	_, nopen = string.gsub(obj, "[(]", "")
	_, nclosed = string.gsub(obj, "[)]", "")
	if nopen ~= nclosed then
		return
	end
	
	-- var muist start with a letter
	if string.find(string.sub(obj, 1, 1), "%d") then
		return
	end
	
	-- var can only contact certain characters
	if string.find(obj, '[^_.()%a%d]', 0) then
		return
	end
	
	-- if we have a close bracket, the next char must be nil or a dot
	if string.find(obj, '[)][_()%a%d]', 0) then
		return
	end
	
	textWindow:SetTitle("Inspector: "..obj)
	
	cmd = assert(loadstring('val='..obj))
	pcall(cmd)
	cmdOutput = getTableDetails(val, obj, depth, 0)
	textField:SetText(cmdOutput)
	textWindow:SetVisible(true)

end

-- Register the slash commands
table.insert(Command.Slash.Register("ti"), {Inspector.showInspectionWindow, "Inspector", "Slash command"})


-- initialisation
init()
initHelp()