class Base
	new: (args) =>
		assert(type(args) == 'table', 'settings.types.Base')
		assert(type(args.title) == 'string', 'settings.types.Base')
		assert(type(args.tooltip) == 'string', 'settings.types.Base')
		assert(type(args.type) == 'number' and args.type % 1 == 0, 'settings.types.Base')
		assert(args.type > 0 and args.type < ENUMS.SETTING_TYPES.MAX, 'settings.types.Base')
		@title = args.title
		@tooltip = args.tooltip
		@type = args.type

	getInc: (index) => assert(nil, 'settings.types.Base.getInc')

class Action extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.ACTION if args.type == nil
		super(args)
		@label = args.label
		@perform = args.perform

	getInc: (index) =>
		return table.concat({
			('[Slot%dAction]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] / 2)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W])')\format(index)
			'H=#ButtonHeight#'
			'StringAlign=CenterCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dAction" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingAction')\format(index, index, index)
			'\n'
		}, '\n')

class Boolean extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.BOOLEAN if args.type == nil
		super(args)
		@getState = args.getState
		@toggle = args.toggle

	toggle: () => return @toggleAction()

	getInc: (index) =>
		return table.concat({
			('[Slot%dBoolean]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\boolean_false.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=#ButtonHeight#'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dBoolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingBoolean')\format(index, index, index)
			'\n'
		}, '\n')

class Integer extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.INTEGER if args.type == nil
		super(args)
		@value = args.defaultValue or 0
		@minValue = args.minValue or nil
		@maxValue = args.maxValue or nil
		@stepValue = args.stepValue or 1
		@getValue = args.getValue if args.getValue ~= nil
		@setValue = args.setValue if args.setValue ~= nil
		@onValueChanged = args.onValueChanged if args.onValueChanged ~= nil

	getValue: () => return @value

	setValue: (value) =>
		return if @minValue ~= nil and value < @minValue
		return if @maxValue ~= nil and value > @maxValue
		@value = value
		@onValueChanged(@value)

	incrementValue: () =>
		return if @maxValue ~= nil and @value + @stepValue > @maxValue
		@value += @stepValue
		@onValueChanged(@value)

	decrementValue: () =>
		return if @minValue ~= nil and @value - @stepValue < @minValue
		@value -= @stepValue
		@onValueChanged(@value)

	onValueChanged: (value) => return

	getInc: (index) =>
		return table.concat({
			('[Slot%dIntegerIncrement]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\integer_increment.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dIntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger')\format(index, index, index)
			''
			('[Slot%dIntegerDecrement]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\integer_decrement.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dIntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger')\format(index, index, index)
			''
			('[Slot%dIntegerValue]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#SettingInputFieldBackgroundColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			'H=#ButtonHeight#'
			'StringAlign=LeftCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(%d)"]')\format(index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingInteger')\format(index, index, index)
			'\n'
		}, '\n')

class FolderPath extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.FOLDER_PATH if args.type == nil
		super(args)
		@getValue = args.getValue
		@setValue = args.setValue
		@dialogTitle = args.dialogTitle or 'Select a folder'

	startBrowsing: () =>
		return ('""cscript \"#@#settings\\folderBrowser.vbs\" \"%s\"""')\format(@dialogTitle)

	getInc: (index) =>
		return table.concat({
			('[Slot%dFolderPathBrowse]')\format(index)
			'Text=Browse'
			'Meter=String'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dBoundingBox:X] + [Slot%dBoundingBox:W] - #ButtonHeight# - 4)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			'W=(2 * #ButtonHeight#)'
			'H=#ButtonHeight#'
			'StringAlign=CenterCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dFolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPath')\format(index, index, index)
			''
			('[Slot%dFolderPathValue]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#SettingInputFieldBackgroundColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W] - [Slot%dFolderPathBrowse:W])')\format(index, index)
			'H=#ButtonHeight#'
			'StringAlign=LeftCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(%d)"]')\format(index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPath')\format(index, index, index)
			'\n'
		}, '\n')

class Spinner extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.SPINNER if args.type == nil
		super(args)
		@index = args.index
		@values = {'UNDEFINED'}
		@getIndex = args.getIndex if args.getIndex ~= nil
		@setIndex = args.setIndex if args.setIndex ~= nil
		@getValues = args.getValues if args.getValues ~= nil
		@setValues = args.setValues if args.setValues ~= nil

	getIndex: () => return @index

	setIndex: (index) =>
		if index < 1
			index = #@getValues()
		elseif index > #@getValues()
			index = 1
		@index = index

	getValues: () => return @values

	setValues: (values) =>
		@values = values
		@setIndex(1)

	getInc: (index) =>
		return table.concat({
			('[Slot%dSpinnerUp]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\spinner_up.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(%d, -1)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner')\format(index, index, index)
			''
			('[Slot%dSpinnerDown]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\spinner_down.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(%d, 1)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner')\format(index, index, index)
			''
			('[Slot%dSpinnerValue]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#SettingInputFieldBackgroundColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W] - #ButtonHeight#)')\format(index, index)
			'H=#ButtonHeight#'
			'StringAlign=LeftCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('Group=Slot%d|Slot%dSettings|Slot%dSettingSpinner')\format(index, index, index)
			'\n'
		}, '\n')

class FolderPathSpinner extends Spinner
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.FOLDER_PATH_SPINNER if args.type == nil
		super(args)
		@setPath = args.setPath if args.setPath ~= nil
		@dialogTitle = args.dialogTitle or 'Select a folder'

	startBrowsing: () =>
		return ('""cscript \"#@#settings\\folderBrowser.vbs\" \"%s\"""')\format(@dialogTitle)

	getIndex: () => return @index

	setIndex: (index) =>
		if index < 1
			index = #@getValues()
		elseif index > #@getValues()
			index = 1
		@index = index

	getValues: () => return @values

	setValues: (values) =>
		@values = values
		@setIndex(1)

	setPath: (index, path) =>
		@values[index] = path

	getInc: (index) =>
		return table.concat({
			('[Slot%dFolderPathSpinnerBrowse]')\format(index)
			'Text=Browse'
			'Meter=String'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dBoundingBox:X] + [Slot%dBoundingBox:W] - #ButtonHeight# - 4)')\format(index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			'W=(2 * #ButtonHeight#)'
			'H=#ButtonHeight#'
			'StringAlign=CenterCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(%d)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner')\format(index, index, index)
			''
			('[Slot%dFolderPathSpinnerUp]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\spinner_up.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])')\format(index, index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H] - #ButtonHeight#) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(%d, -1)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner')\format(index, index, index)
			''
			('[Slot%dFolderPathSpinnerDown]')\format(index)
			'Meter=Image'
			'ImageName=#@#settings\\gfx\\spinner_down.png'
			'SolidColor=#ButtonBaseColor#'
			('X=([Slot%dTitle:X] + [Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])')\format(index, index, index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			'W=#ButtonHeight#'
			'H=(#ButtonHeight# / 2)'
			'DynamicVariables=1'
			('MouseOverAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]')\format(index)
			('MouseLeaveAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]')\format(index)
			('LeftMouseDownAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]')\format(index)
			('LeftMouseUpAction=[!SetOption "Slot%dFolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(%d, 1)"]')\format(index, index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner')\format(index, index, index)
			''
			('[Slot%dFolderPathSpinnerValue]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#SettingInputFieldBackgroundColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W] - #ButtonHeight# - [Slot%dFolderPathSpinnerBrowse:W])')\format(index, index, index)
			'H=#ButtonHeight#'
			'StringAlign=LeftCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(%d)"]')\format(index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingFolderPathSpinner')\format(index, index, index)
			'\n'
		}, '\n')

class String extends Base
	new: (args) =>
		args.type = ENUMS.SETTING_TYPES.STRING if args.type == nil
		super(args)
		@getValue = args.getValue
		@setValue = args.setValue
		@dialogTitle = args.dialogTitle or 'Select a folder'

	getInc: (index) =>
		return table.concat({
			('[Slot%dStringValue]')\format(index)
			'Text=UNDEFINED'
			'Meter=String'
			'SolidColor=#SettingInputFieldBackgroundColor#'
			('X=([Slot%dTitle:X])')\format(index)
			('Y=([Slot%dTitle:Y] + [Slot%dTitle:H] + ([Slot%dBoundingBox:H] - [Slot%dTitle:H]) / 2)')\format(index, index, index, index)
			('W=([Slot%dTitle:W])')\format(index, index)
			'H=#ButtonHeight#'
			'StringAlign=LeftCenter'
			'StringStyle=Bold'
			'FontSize=16'
			'AntiAlias=1'
			'DynamicVariables=1'
			('LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingString(%d)"]')\format(index)
			('Group=Slot%d|Slot%dSettings|Slot%dSettingString')\format(index, index, index)
			'\n'
		}, '\n')

return {
	:Action
	:Boolean
	:Integer
	:FolderPath
	:Spinner
	:FolderPathSpinner
	:String
}
