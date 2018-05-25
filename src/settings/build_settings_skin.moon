build = () ->
	contents = '[SlotBackground]
Meter=Image
SolidColor=0,0,0,1
X=([WindowBackground:X] + 2)
Y=([WindowBackground:Y] + #TitleBarHeight#)
W=([WindowBackground:W] - 3)
H=([WindowBackground:H] - #TitleBarHeight# - #ButtonHeight#)
MouseScrollUpAction=[!CommandMeasure "Script" "ScrollSlots(-1)"]
MouseScrollDownAction=[!CommandMeasure "Script" "ScrollSlots(1)"]
DynamicVariables=1
'
	-- Scrollbar
	contents ..= '
[ScrollBarBackground]
Meter=Image
SolidColor=#ScrollbarBackgroundColor#
X=([WindowBackground:X] + [WindowBackground:W] - #ScrollBarWidth#)
Y=([SlotBackground:Y])
W=#ScrollBarWidth#
H=([SlotBackground:H])
DynamicVariables=1

[ScrollBar]
Meter=Image
SolidColor=#ScrollbarColor#
X=([ScrollBarBackground:X] + 1)
Y=([ScrollBarBackground:Y] + 1)
W=([ScrollBarBackground:W] - 1)
H=([ScrollBarBackground:H] - 2)
DynamicVariables=1
'
	-- FolderPath
	contents ..= '
[FolderPathInput]
Measure=Plugin
Plugin=InputText
SolidColor=#WindowBackgroundColor#
X=0
Y=0
W=0
H=0
DefaultValue=
StringAlign=Left
StringStyle=Bold
FontSize=16
DynamicVariables=1'
	
	for i = 1, STATE.NUM_SLOTS
		contents ..= ('Command%d=[!CommandMeasure "Script" "EditFolderPath(%d, \'$UserInput$;\')"]\n')\format(i, i)
	contents ..= '\n'

-- FolderPath
	contents ..= '
[FolderPathSpinnerInput]
Measure=Plugin
Plugin=InputText
SolidColor=#WindowBackgroundColor#
X=0
Y=0
W=0
H=0
DefaultValue=
StringAlign=Left
StringStyle=Bold
FontSize=16
DynamicVariables=1'

	for i = 1, STATE.NUM_SLOTS
		contents ..= ('Command%d=[!CommandMeasure "Script" "EditFolderPathSpinner(%d, \'$UserInput$;\')"]\n')\format(i, i)
	contents ..= '\n'

	contents ..= '
[IntegerInput]
Measure=Plugin
Plugin=InputText
SolidColor=#WindowBackgroundColor#
X=0
Y=0
W=0
H=0
DefaultValue=
InputNumber=1
StringAlign=Left
StringStyle=Bold
FontSize=16
DynamicVariables=1
'
	for i = 1, STATE.NUM_SLOTS
		contents ..= ('Command%d=[!CommandMeasure "Script" "EditInteger(%d, \'$UserInput$\')"]\n')\format(i, i)
	contents ..= '\n'

	Settings = require('settings.types')
	args = {
		title: ''
		tooltip: ''
	}
	settings = [Setting(args) for key, Setting in pairs(Settings)]
	for i = 1, STATE.NUM_SLOTS
		contents ..= table.concat({
			-- Bounding box
			('[Slot%dBoundingBox]')\format(i)
			'Meter=Image'
			'SolidColor=0,0,0,1'
			'X=([SlotBackground:X])'
			('Y=([SlotBackground:Y] + %d * [SlotBackground:H] / %d)')\format(i - 1, STATE.NUM_SLOTS)
			'W=([SlotBackground:W] - #ScrollBarWidth# - 2)'
			('H=([SlotBackground:H] / %d)')\format(STATE.NUM_SLOTS)
			'DynamicVariables=1'
			('Group=Slot%d')\format(i)
			''
			-- Tooltip
			('[Slot%dToolTip]')\format(i)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\tooltip.png'
			'SolidColor=0,0,0,1'
			('X=([Slot%dBoundingBox:X] + 2)')\format(i)
			('Y=([Slot%dBoundingBox:Y] + 8)')\format(i)
			'W=16'
			'H=16'
			('ToolTipText=Slot %d')\format(i)
			('Group=Slot%d')\format(i)
			''
			-- Title
			('[Slot%dTitle]')\format(i)
			'Meter=String'
			('Text=Slot %d')\format(i)
			'StringAlign=LeftCenter'
			'SolidColor=0,0,0,1'
			'X=2R'
			'Y=8r'
			'FontSize=16'
			'AntiAlias=1'
			'StringStyle=Bold'
			('W=([Slot%dBoundingBox:W] - 24)')\format(i)
			'H=32'
			'ClipString=1'
			'DynamicVariables=1'
			('Group=Slot%d')\format(i)
			'\n'
		}, '\n')
		-- Each type of setting
		for setting in *settings
			contents ..= setting\getInc(i)
		if i < STATE.NUM_SLOTS
			i += 1
			contents ..= table.concat({
				-- Separator
				('[Slot%dSeparator]')\format(i)
				'Meter=Image'
				'SolidColor=#SlotSeparatorColor#'
				'X=([WindowBackground:X] + 2)'
				('Y=([Slot%dBoundingBox:Y] + [Slot%dBoundingBox:H] - 1)')\format(i - 1, i - 1)
				('W=([Slot%dBoundingBox:W])')\format(i - 1)
				'H=2'
				'DynamicVariables=1'
				('Group=Slot%d')\format(i)
				'\n'
			}, '\n')
	return contents

return build
