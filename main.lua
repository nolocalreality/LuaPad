--[[
	Project: LuaPad
	Version: 1.5.0
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
LuaPad = {}

local context = UI.CreateContext("LuaPadContext")
local luaPadWindow = UI.CreateFrame("SimpleWindow", "LuaPadluaPadWindow", context) 
local scriptList = UI.CreateFrame("Text", "LuaPadScriptList", luaPadWindow)
local scriptListSeperator = UI.CreateFrame("Frame", "LuaPadScriptListSeperator", luaPadWindow)
local outputSeperator = UI.CreateFrame("Frame", "LuaPadOutputSeperator", luaPadWindow)
local inputFieldScroll = UI.CreateFrame("SimpleScrollView", "LuaPadInputFieldScroll", luaPadWindow:GetContent())
local outputFieldScroll = UI.CreateFrame("SimpleScrollView", "LuaPadOutputFieldScroll", luaPadWindow:GetContent())
local inputField = nil
local outputField = nil
local closeButton = UI.CreateFrame("Texture", "LuaPadCloseButton", luaPadWindow)
local loadButton = UI.CreateFrame("RiftButton", "LuaPadloadButton", luaPadWindow)
local saveButton = UI.CreateFrame("RiftButton", "LuaPadsaveButton", luaPadWindow)
local delButton = UI.CreateFrame("RiftButton", "LuaPaddelButton", luaPadWindow)
local runButton = UI.CreateFrame("RiftButton", "LuaPadrunButton", luaPadWindow)
local helpButton = UI.CreateFrame("RiftButton", "LuaPadhelpButton", luaPadWindow)
local inspectButton = UI.CreateFrame("RiftButton", "LuaPadinspectButton", luaPadWindow)


local label1 = UI.CreateFrame("Text", "LuaPadLabel1", luaPadWindow)
local label2 = UI.CreateFrame("Text", "LuaPadLabel2", luaPadWindow)
local label3 = UI.CreateFrame("Text", "LuaPadLabel3", luaPadWindow)
	
local snippetButtons = {}
local selectedSnippet = nil

local origPrint = nil

local isRunning = false
	
-- Addon initialisation
local function init()

	luaPadWindow:SetVisible(false)
	
	luaPadWindow:SetWidth(840)
	luaPadWindow:SetHeight(600)
	luaPadWindow:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 100, 100)
	luaPadWindow:SetTitle("LuaPad")
	luaPadWindow:SetLayer(1)
	luaPadWindow:SetAlpha(0.8)
	
	scriptListSeperator:SetWidth(2)
	scriptListSeperator:SetBackgroundColor(0,0,0,0.5)
	scriptListSeperator:SetHeight(542)
	scriptListSeperator:SetPoint("TOPRIGHT", luaPadWindow, "TOPRIGHT", -294, 46)
	
	outputSeperator:SetWidth(530)
	outputSeperator:SetBackgroundColor(0,0,0,0.5)
	outputSeperator:SetHeight(2)
	outputSeperator:SetPoint("LEFTCENTER", luaPadWindow, "LEFTCENTER", 14, 100)	
	
	scriptList:SetWidth(280)
	scriptList:SetHeight(480)
	scriptList:SetPoint("TOPRIGHT", luaPadWindow, "TOPRIGHT", -12, 60)	
	scriptList:SetLayer(1)
	
	inputFieldScroll:SetWidth(500)
	inputFieldScroll:SetHeight(300)
	inputFieldScroll:SetBorder(1,1,1,1,0.2)
	inputFieldScroll:SetPoint("TOPLEFT", luaPadWindow, "TOPLEFT", 32, 70)
	inputField = UI.CreateFrame("RiftTextfield", "LuaPadInputField", inputFieldScroll)
	inputField:SetBackgroundColor(0,0,0,0.5)
	inputField:SetHeight(300)
	inputField:SetText("")
	inputFieldScroll:SetContent(inputField)
	
	outputFieldScroll:SetWidth(500)
	outputFieldScroll:SetHeight(150)
	outputFieldScroll:SetBorder(1,1,1,1,0.2)
	outputFieldScroll:SetPoint("TOPLEFT", luaPadWindow, "TOPLEFT", 32, 418)
	outputField = UI.CreateFrame("Text", "LuaPadOutputField", outputFieldScroll)
	outputField:SetBackgroundColor(0,0,0,0.5)
	outputField:SetHeight(150)
	outputFieldScroll:SetContent(outputField)
	
	function inputField.Event:KeyDown(button)
		--local code = string.byte(button) doesn't work, enter and right arrow both are 82
		local txt = inputField:GetText()
		local pos = inputField:GetCursor()
		-- split txt into two by pos
		local txtPre = string.sub(txt, 0, pos)
		local txtPost = string.sub(txt, pos+1)
		inputField:SetKeyFocus(true) 
		if button == "Return" then
			inputField:SetText(txtPre.."\n"..txtPost)
			inputField:SetCursor(pos+1)
		elseif button == "Tab" then
			inputField:SetText(txtPre.."\t "..txtPost)
			inputField:SetCursor(pos+1)
		end	

		
		-- resize inputField
		_, count = string.gsub(inputField:GetText(), "\r", "\r")
		local t = inputField:GetText()
		inputField:SetHeight(math.max(14*(count), 300))
	end	
	
	loadButton:SetText("Load")
	loadButton:SetPoint("BOTTOMRIGHT", luaPadWindow, "BOTTOMRIGHT", -194, -20)	
	loadButton:SetWidth(100)
	function loadButton.Event:LeftPress()
		loadSnippet()
	end	
	loadButton:SetLayer(2)
	saveButton:SetText("Save")
	saveButton:SetPoint("BOTTOMRIGHT", luaPadWindow, "BOTTOMRIGHT", -104, -20)	
	saveButton:SetWidth(100)
	function saveButton.Event:LeftPress()
		saveSnippet()
	end	
	saveButton:SetLayer(2)
	delButton:SetText("Clear")
	delButton:SetPoint("BOTTOMRIGHT", luaPadWindow, "BOTTOMRIGHT", -14, -20)	
	delButton:SetWidth(100)
	function delButton.Event:LeftPress()
		clearSnippet()
	end		
	delButton:SetLayer(2)
	
	runButton:SetText("Run")
	runButton:SetWidth(100)
	runButton:SetPoint("LEFTCENTER", luaPadWindow, "LEFTCENTER", 100, 85)	
	function runButton.Event:LeftPress()
		LuaPad.doRun(inputField:GetText())
	end	
	
	inspectButton:SetText("Inspect")
	inspectButton:SetWidth(100)
	inspectButton:SetPoint("LEFTCENTER", luaPadWindow, "LEFTCENTER", 236, 85)	
	function inspectButton.Event:LeftPress()
		Inspector.showInspectionWindow()
	end		

	helpButton:SetText("Help")
	helpButton:SetWidth(100)
	helpButton:SetPoint("CENTERCENTER", luaPadWindow, "CENTERCENTER", 0, 85)	
	function helpButton.Event:LeftPress()
		outputField:SetText("Help has yet to be written.\nThe next release will include Lua and  Rift API documentation.\nSnippet saving does not currently save on logout... sorry.")
	end	
	

	closeButton:SetTexture("LuaPad", "close.png")
	closeButton:SetPoint("TOPRIGHT", luaPadWindow, "TOPRIGHT", -8, 16)	
	function closeButton.Event:LeftClick()
		inputField:SetKeyFocus(false)
		luaPadWindow:SetVisible(false)
	end		
	
	label1:SetPoint("TOPLEFT", luaPadWindow, "TOPLEFT", 30, 52)	
	label1:SetText("Code Editor")
	label1:SetFontColor(1,1,1,0.6)	
	
	label2:SetPoint("TOPLEFT", luaPadWindow, "TOPLEFT", 30, 400)	
	label2:SetText("Output")
	label2:SetFontColor(1,1,1,0.6)		
	
	label3:SetPoint("TOPRIGHT", luaPadWindow, "TOPRIGHT", -244, 52)	
	label3:SetText("Code Snippets")
	label3:SetFontColor(1,1,1,0.6)	
	
end


-- display LuaPad
local function showLuaPad()
	luaPadWindow:SetVisible(true)
end


-- run the code!
function LuaPad.doRun(obj)
	if( (obj == nil) or (obj == "") ) then
		outputField:SetText('Please enter some Lua code and then press run.')
		return
	end
	isRunning=true
	outputField:SetText('')
	outputField:SetHeight(150)
	
	function xpError(obj)
		print(" ")
		print("Error: "..obj)
		dump(debug.traceback)
	end
	local retOK, ret1 = xpcall(loadstring(obj), xpError);
	isRunning=false
end


-- create the snippet buttons
local function createSnippetButtons()
	local textMargin = 10
	for i=1,16 do
	
		local text = UI.CreateFrame("Text", "LuaPadSnippetButton", scriptList)
		if math.fmod(i, 2) ~= 0 then
			text:SetPoint("TOPLEFT", scriptList, "TOPLEFT", textMargin, textMargin+(((i/2)*60)-30))
		else
			text:SetPoint("TOPLEFT", scriptList, "TOPLEFT", textMargin+((280-(2*textMargin))/2), textMargin+((((i-1)/2)*60)-30))
		end
		text:SetWidth((270-(2*textMargin))/2)
		text:SetHeight(60-(textMargin/2))		
		text:SetBackgroundColor(1,0,0,0.2)		
		text:SetFontColor(1,1,1)
		text:SetFontSize(8)
		text:SetWordwrap(false)
		text:SetText('')
		function text.Event:LeftClick()
			for j=1,16 do
				-- set background colours to normal
				snippetButtons[j]:SetBackgroundColor(1,0,0,0.2)	
			end
			-- highlight
			text:SetBackgroundColor(0,1,0,0.2)	
			-- select
			selectedSnippet = i
		end		

		-- add to notifications table
		snippetButtons[i] = text
	end
end

-- Update snippet buttons
function fillSnippetButtons()
	for i=1,13 do
		if LuaPad_Snippets[i] then
			snippetButtons[i]:SetText(LuaPad_Snippets[i])
		else
			snippetButtons[i]:SetText('')
		end

	end
end


-- load a snippet
function loadSnippet()
	if(selectedSnippet) then
		local snippet = LuaPad_Snippets[selectedSnippet]
		if snippet then
			inputField:SetText(snippet)
		else
			inputField:SetText("")
		end
		snippetButtons[selectedSnippet]:SetBackgroundColor(0,1,0,0.1)
	end
end

-- save a snippet
function saveSnippet()
    if not selectedSnippet then return end
	local snippet = inputField:GetText()
	LuaPad_Snippets[selectedSnippet]=snippet
	fillSnippetButtons()
end


-- clear a snippet
function clearSnippet()
	LuaPad_Snippets[selectedSnippet]=''
	fillSnippetButtons()
end


-- save snippets to saved variable
function saveVar(addon)
	if addon == "LuaPad" then
	end
end

local function hookPrint()
	origPrint = print
	print = LuaPad.print
end

-- load snippets from saved variables
function loadVar(addon)
	if addon == "LuaPad" then
		LuaPad_Snippets = LuaPad_Snippets or { }
		fillSnippetButtons()
		loadSnippet()
	end
end

function LuaPad.print(arg)
	if(isRunning) then
		outputField:SetText(outputField:GetText()..'\r'..arg)
		_, count = string.gsub(outputField:GetText(), "\r", "\r")
		local t = outputField:GetText()
		outputField:SetHeight(math.max(14*(count), 150))	
	else
		origPrint(arg)
	end
end

-- Register the slash commands
table.insert(Command.Slash.Register("luapad"), {showLuaPad, "LuaPad", "Slash command"})
table.insert(Command.Slash.Register("lp"), {showLuaPad, "LuaPad", "Slash command"})
table.insert(Event.Addon.SavedVariables.Save.Begin, {saveVar, "LuaPad", "Save variables"})
table.insert(Event.Addon.SavedVariables.Load.End, {loadVar, "LuaPad", "Load variables"})

-- initialisation
init()
createSnippetButtons()
loadSnippet()
hookPrint()