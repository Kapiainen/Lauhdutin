[SlotBackground]
Meter=Image
SolidColor=0,0,0,1
X=([WindowBackground:X] + 2)
Y=([WindowBackground:Y] + #TitleBarHeight#)
W=([WindowBackground:W] - 3)
H=([WindowBackground:H] - #TitleBarHeight# - #ButtonHeight#)
MouseScrollUpAction=[!CommandMeasure "Script" "ScrollSlots(-1)"]
MouseScrollDownAction=[!CommandMeasure "Script" "ScrollSlots(1)"]
DynamicVariables=1

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
DynamicVariables=1Command1=[!CommandMeasure "Script" "EditFolderPath(1, '$UserInput$;')"]
Command2=[!CommandMeasure "Script" "EditFolderPath(2, '$UserInput$;')"]
Command3=[!CommandMeasure "Script" "EditFolderPath(3, '$UserInput$;')"]
Command4=[!CommandMeasure "Script" "EditFolderPath(4, '$UserInput$;')"]


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
DynamicVariables=1Command1=[!CommandMeasure "Script" "EditFolderPathSpinner(1, '$UserInput$;')"]
Command2=[!CommandMeasure "Script" "EditFolderPathSpinner(2, '$UserInput$;')"]
Command3=[!CommandMeasure "Script" "EditFolderPathSpinner(3, '$UserInput$;')"]
Command4=[!CommandMeasure "Script" "EditFolderPathSpinner(4, '$UserInput$;')"]


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
Command1=[!CommandMeasure "Script" "EditInteger(1, '$UserInput$')"]
Command2=[!CommandMeasure "Script" "EditInteger(2, '$UserInput$')"]
Command3=[!CommandMeasure "Script" "EditInteger(3, '$UserInput$')"]
Command4=[!CommandMeasure "Script" "EditInteger(4, '$UserInput$')"]

[Slot1BoundingBox]
Meter=Image
SolidColor=0,0,0,1
X=([SlotBackground:X])
Y=([SlotBackground:Y] + 0 * [SlotBackground:H] / 4)
W=([SlotBackground:W] - #ScrollBarWidth# - 2)
H=([SlotBackground:H] / 4)
DynamicVariables=1
Group=Slot1

[Slot1ToolTip]
Meter=Image
ImageName=#@#settings\gfx\tooltip.png
SolidColor=0,0,0,1
X=([Slot1BoundingBox:X] + 2)
Y=([Slot1BoundingBox:Y] + 8)
W=16
H=16
ToolTipText=Slot 1
Group=Slot1

[Slot1Title]
Meter=String
Text=Slot 1
StringAlign=LeftCenter
SolidColor=0,0,0,1
X=2R
Y=8r
FontSize=16
AntiAlias=1
StringStyle=Bold
W=([Slot1BoundingBox:W] - 24)
H=32
ClipString=1
DynamicVariables=1
Group=Slot1

[Slot1Action]
Text=UNDEFINED
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] / 2)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=([Slot1Title:W])
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1Action" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1Action" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1Action" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1Action" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(1)"]
Group=Slot1|Slot1Settings|Slot1SettingAction

[Slot1IntegerIncrement]
Meter=Image
ImageName=#@#settings\gfx\integer_increment.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight#)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1IntegerIncrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1IntegerIncrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(1)"]
Group=Slot1|Slot1Settings|Slot1SettingInteger

[Slot1IntegerDecrement]
Meter=Image
ImageName=#@#settings\gfx\integer_decrement.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight#)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1IntegerDecrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1IntegerDecrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(1)"]
Group=Slot1|Slot1Settings|Slot1SettingInteger

[Slot1IntegerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot1Title:X])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=([Slot1Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(1)"]
Group=Slot1|Slot1Settings|Slot1SettingInteger

[Slot1FolderPathSpinnerBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot1BoundingBox:X] + [Slot1BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1FolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1FolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPathSpinner

[Slot1FolderPathSpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight# - [Slot1FolderPathSpinnerBrowse:W])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1FolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1FolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(1, -1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPathSpinner

[Slot1FolderPathSpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight# - [Slot1FolderPathSpinnerBrowse:W])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1FolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1FolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(1, 1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPathSpinner

[Slot1FolderPathSpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot1Title:X])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=([Slot1Title:W] - #ButtonHeight# - [Slot1FolderPathSpinnerBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPathSpinner

[Slot1FolderPathBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot1BoundingBox:X] + [Slot1BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1FolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1FolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPath

[Slot1FolderPathValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot1Title:X])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=([Slot1Title:W] - [Slot1FolderPathBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(1)"]
Group=Slot1|Slot1Settings|Slot1SettingFolderPath

[Slot1Boolean]
Meter=Image
ImageName=#@#settings\gfx\boolean_false.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=#ButtonHeight#
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1Boolean" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1Boolean" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1Boolean" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1Boolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(1)"]
Group=Slot1|Slot1Settings|Slot1SettingBoolean

[Slot1SpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight#)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1SpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1SpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(1, -1)"]
Group=Slot1|Slot1Settings|Slot1SettingSpinner

[Slot1SpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot1Title:X] + [Slot1Title:W] - #ButtonHeight#)
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot1SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot1SpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot1SpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot1SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(1, 1)"]
Group=Slot1|Slot1Settings|Slot1SettingSpinner

[Slot1SpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot1Title:X])
Y=([Slot1Title:Y] + [Slot1Title:H] + ([Slot1BoundingBox:H] - [Slot1Title:H]) / 2)
W=([Slot1Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
Group=Slot1|Slot1Settings|Slot1SettingSpinner

[Slot2Separator]
Meter=Image
SolidColor=#SlotSeparatorColor#
X=([WindowBackground:X] + 2)
Y=([Slot1BoundingBox:Y] + [Slot1BoundingBox:H] - 1)
W=([Slot1BoundingBox:W])
H=2
DynamicVariables=1
Group=Slot2

[Slot2BoundingBox]
Meter=Image
SolidColor=0,0,0,1
X=([SlotBackground:X])
Y=([SlotBackground:Y] + 1 * [SlotBackground:H] / 4)
W=([SlotBackground:W] - #ScrollBarWidth# - 2)
H=([SlotBackground:H] / 4)
DynamicVariables=1
Group=Slot2

[Slot2ToolTip]
Meter=Image
ImageName=#@#settings\gfx\tooltip.png
SolidColor=0,0,0,1
X=([Slot2BoundingBox:X] + 2)
Y=([Slot2BoundingBox:Y] + 8)
W=16
H=16
ToolTipText=Slot 2
Group=Slot2

[Slot2Title]
Meter=String
Text=Slot 2
StringAlign=LeftCenter
SolidColor=0,0,0,1
X=2R
Y=8r
FontSize=16
AntiAlias=1
StringStyle=Bold
W=([Slot2BoundingBox:W] - 24)
H=32
ClipString=1
DynamicVariables=1
Group=Slot2

[Slot2Action]
Text=UNDEFINED
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] / 2)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=([Slot2Title:W])
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2Action" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2Action" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2Action" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2Action" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(2)"]
Group=Slot2|Slot2Settings|Slot2SettingAction

[Slot2IntegerIncrement]
Meter=Image
ImageName=#@#settings\gfx\integer_increment.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight#)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2IntegerIncrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2IntegerIncrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(2)"]
Group=Slot2|Slot2Settings|Slot2SettingInteger

[Slot2IntegerDecrement]
Meter=Image
ImageName=#@#settings\gfx\integer_decrement.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight#)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2IntegerDecrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2IntegerDecrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(2)"]
Group=Slot2|Slot2Settings|Slot2SettingInteger

[Slot2IntegerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot2Title:X])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=([Slot2Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(2)"]
Group=Slot2|Slot2Settings|Slot2SettingInteger

[Slot2FolderPathSpinnerBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot2BoundingBox:X] + [Slot2BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2FolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2FolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(2)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPathSpinner

[Slot2FolderPathSpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight# - [Slot2FolderPathSpinnerBrowse:W])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2FolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2FolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(2, -1)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPathSpinner

[Slot2FolderPathSpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight# - [Slot2FolderPathSpinnerBrowse:W])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2FolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2FolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(2, 1)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPathSpinner

[Slot2FolderPathSpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot2Title:X])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=([Slot2Title:W] - #ButtonHeight# - [Slot2FolderPathSpinnerBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(2)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPathSpinner

[Slot2FolderPathBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot2BoundingBox:X] + [Slot2BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2FolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2FolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(2)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPath

[Slot2FolderPathValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot2Title:X])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=([Slot2Title:W] - [Slot2FolderPathBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(2)"]
Group=Slot2|Slot2Settings|Slot2SettingFolderPath

[Slot2Boolean]
Meter=Image
ImageName=#@#settings\gfx\boolean_false.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=#ButtonHeight#
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2Boolean" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2Boolean" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2Boolean" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2Boolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(2)"]
Group=Slot2|Slot2Settings|Slot2SettingBoolean

[Slot2SpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight#)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2SpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2SpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(2, -1)"]
Group=Slot2|Slot2Settings|Slot2SettingSpinner

[Slot2SpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot2Title:X] + [Slot2Title:W] - #ButtonHeight#)
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot2SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot2SpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot2SpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot2SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(2, 1)"]
Group=Slot2|Slot2Settings|Slot2SettingSpinner

[Slot2SpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot2Title:X])
Y=([Slot2Title:Y] + [Slot2Title:H] + ([Slot2BoundingBox:H] - [Slot2Title:H]) / 2)
W=([Slot2Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
Group=Slot2|Slot2Settings|Slot2SettingSpinner

[Slot3Separator]
Meter=Image
SolidColor=#SlotSeparatorColor#
X=([WindowBackground:X] + 2)
Y=([Slot2BoundingBox:Y] + [Slot2BoundingBox:H] - 1)
W=([Slot2BoundingBox:W])
H=2
DynamicVariables=1
Group=Slot3

[Slot3BoundingBox]
Meter=Image
SolidColor=0,0,0,1
X=([SlotBackground:X])
Y=([SlotBackground:Y] + 2 * [SlotBackground:H] / 4)
W=([SlotBackground:W] - #ScrollBarWidth# - 2)
H=([SlotBackground:H] / 4)
DynamicVariables=1
Group=Slot3

[Slot3ToolTip]
Meter=Image
ImageName=#@#settings\gfx\tooltip.png
SolidColor=0,0,0,1
X=([Slot3BoundingBox:X] + 2)
Y=([Slot3BoundingBox:Y] + 8)
W=16
H=16
ToolTipText=Slot 3
Group=Slot3

[Slot3Title]
Meter=String
Text=Slot 3
StringAlign=LeftCenter
SolidColor=0,0,0,1
X=2R
Y=8r
FontSize=16
AntiAlias=1
StringStyle=Bold
W=([Slot3BoundingBox:W] - 24)
H=32
ClipString=1
DynamicVariables=1
Group=Slot3

[Slot3Action]
Text=UNDEFINED
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] / 2)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=([Slot3Title:W])
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3Action" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3Action" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3Action" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3Action" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(3)"]
Group=Slot3|Slot3Settings|Slot3SettingAction

[Slot3IntegerIncrement]
Meter=Image
ImageName=#@#settings\gfx\integer_increment.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight#)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3IntegerIncrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3IntegerIncrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(3)"]
Group=Slot3|Slot3Settings|Slot3SettingInteger

[Slot3IntegerDecrement]
Meter=Image
ImageName=#@#settings\gfx\integer_decrement.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight#)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3IntegerDecrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3IntegerDecrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(3)"]
Group=Slot3|Slot3Settings|Slot3SettingInteger

[Slot3IntegerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot3Title:X])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=([Slot3Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(3)"]
Group=Slot3|Slot3Settings|Slot3SettingInteger

[Slot3FolderPathSpinnerBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot3BoundingBox:X] + [Slot3BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3FolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3FolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(3)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPathSpinner

[Slot3FolderPathSpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight# - [Slot3FolderPathSpinnerBrowse:W])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3FolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3FolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(3, -1)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPathSpinner

[Slot3FolderPathSpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight# - [Slot3FolderPathSpinnerBrowse:W])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3FolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3FolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(3, 1)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPathSpinner

[Slot3FolderPathSpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot3Title:X])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=([Slot3Title:W] - #ButtonHeight# - [Slot3FolderPathSpinnerBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(3)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPathSpinner

[Slot3FolderPathBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot3BoundingBox:X] + [Slot3BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3FolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3FolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(3)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPath

[Slot3FolderPathValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot3Title:X])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=([Slot3Title:W] - [Slot3FolderPathBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(3)"]
Group=Slot3|Slot3Settings|Slot3SettingFolderPath

[Slot3Boolean]
Meter=Image
ImageName=#@#settings\gfx\boolean_false.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=#ButtonHeight#
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3Boolean" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3Boolean" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3Boolean" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3Boolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(3)"]
Group=Slot3|Slot3Settings|Slot3SettingBoolean

[Slot3SpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight#)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3SpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3SpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(3, -1)"]
Group=Slot3|Slot3Settings|Slot3SettingSpinner

[Slot3SpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot3Title:X] + [Slot3Title:W] - #ButtonHeight#)
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot3SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot3SpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot3SpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot3SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(3, 1)"]
Group=Slot3|Slot3Settings|Slot3SettingSpinner

[Slot3SpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot3Title:X])
Y=([Slot3Title:Y] + [Slot3Title:H] + ([Slot3BoundingBox:H] - [Slot3Title:H]) / 2)
W=([Slot3Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
Group=Slot3|Slot3Settings|Slot3SettingSpinner

[Slot4Separator]
Meter=Image
SolidColor=#SlotSeparatorColor#
X=([WindowBackground:X] + 2)
Y=([Slot3BoundingBox:Y] + [Slot3BoundingBox:H] - 1)
W=([Slot3BoundingBox:W])
H=2
DynamicVariables=1
Group=Slot4

[Slot4BoundingBox]
Meter=Image
SolidColor=0,0,0,1
X=([SlotBackground:X])
Y=([SlotBackground:Y] + 3 * [SlotBackground:H] / 4)
W=([SlotBackground:W] - #ScrollBarWidth# - 2)
H=([SlotBackground:H] / 4)
DynamicVariables=1
Group=Slot4

[Slot4ToolTip]
Meter=Image
ImageName=#@#settings\gfx\tooltip.png
SolidColor=0,0,0,1
X=([Slot4BoundingBox:X] + 2)
Y=([Slot4BoundingBox:Y] + 8)
W=16
H=16
ToolTipText=Slot 4
Group=Slot4

[Slot4Title]
Meter=String
Text=Slot 4
StringAlign=LeftCenter
SolidColor=0,0,0,1
X=2R
Y=8r
FontSize=16
AntiAlias=1
StringStyle=Bold
W=([Slot4BoundingBox:W] - 24)
H=32
ClipString=1
DynamicVariables=1
Group=Slot4

[Slot4Action]
Text=UNDEFINED
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] / 2)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=([Slot4Title:W])
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4Action" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4Action" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4Action" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4Action" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "PerformAction(4)"]
Group=Slot4|Slot4Settings|Slot4SettingAction

[Slot4IntegerIncrement]
Meter=Image
ImageName=#@#settings\gfx\integer_increment.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight#)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4IntegerIncrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4IntegerIncrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4IntegerIncrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "IncrementInteger(4)"]
Group=Slot4|Slot4Settings|Slot4SettingInteger

[Slot4IntegerDecrement]
Meter=Image
ImageName=#@#settings\gfx\integer_decrement.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight#)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4IntegerDecrement" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4IntegerDecrement" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4IntegerDecrement" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "DecrementInteger(4)"]
Group=Slot4|Slot4Settings|Slot4SettingInteger

[Slot4IntegerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot4Title:X])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=([Slot4Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingIntegerPath(4)"]
Group=Slot4|Slot4Settings|Slot4SettingInteger

[Slot4FolderPathSpinnerBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot4BoundingBox:X] + [Slot4BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4FolderPathSpinnerBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4FolderPathSpinnerBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4FolderPathSpinnerBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPathSpinner(4)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPathSpinner

[Slot4FolderPathSpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight# - [Slot4FolderPathSpinnerBrowse:W])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4FolderPathSpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4FolderPathSpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4FolderPathSpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(4, -1)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPathSpinner

[Slot4FolderPathSpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight# - [Slot4FolderPathSpinnerBrowse:W])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4FolderPathSpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4FolderPathSpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4FolderPathSpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleFolderPathSpinner(4, 1)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPathSpinner

[Slot4FolderPathSpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot4Title:X])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=([Slot4Title:W] - #ButtonHeight# - [Slot4FolderPathSpinnerBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPathSpinner(4)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPathSpinner

[Slot4FolderPathBrowse]
Text=Browse
Meter=String
SolidColor=#ButtonBaseColor#
X=([Slot4BoundingBox:X] + [Slot4BoundingBox:W] - #ButtonHeight# - 4)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=(2 * #ButtonHeight#)
H=#ButtonHeight#
StringAlign=CenterCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4FolderPathBrowse" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4FolderPathBrowse" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4FolderPathBrowse" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "StartBrowsingFolderPath(4)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPath

[Slot4FolderPathValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot4Title:X])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=([Slot4Title:W] - [Slot4FolderPathBrowse:W])
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "StartEditingFolderPath(4)"]
Group=Slot4|Slot4Settings|Slot4SettingFolderPath

[Slot4Boolean]
Meter=Image
ImageName=#@#settings\gfx\boolean_false.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=#ButtonHeight#
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4Boolean" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4Boolean" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4Boolean" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4Boolean" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "ToggleBoolean(4)"]
Group=Slot4|Slot4Settings|Slot4SettingBoolean

[Slot4SpinnerUp]
Meter=Image
ImageName=#@#settings\gfx\spinner_up.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight#)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H] - #ButtonHeight#) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4SpinnerUp" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4SpinnerUp" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4SpinnerUp" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(4, -1)"]
Group=Slot4|Slot4Settings|Slot4SettingSpinner

[Slot4SpinnerDown]
Meter=Image
ImageName=#@#settings\gfx\spinner_down.png
SolidColor=#ButtonBaseColor#
X=([Slot4Title:X] + [Slot4Title:W] - #ButtonHeight#)
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=#ButtonHeight#
H=(#ButtonHeight# / 2)
DynamicVariables=1
MouseOverAction=[!SetOption "Slot4SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"]
MouseLeaveAction=[!SetOption "Slot4SpinnerDown" "SolidColor" "#ButtonBaseColor#"]
LeftMouseDownAction=[!SetOption "Slot4SpinnerDown" "SolidColor" "#ButtonPressedColor#"]
LeftMouseUpAction=[!SetOption "Slot4SpinnerDown" "SolidColor" "#ButtonHighlightedColor#"][!CommandMeasure "Script" "CycleSpinner(4, 1)"]
Group=Slot4|Slot4Settings|Slot4SettingSpinner

[Slot4SpinnerValue]
Text=UNDEFINED
Meter=String
SolidColor=#SettingInputFieldBackgroundColor#
X=([Slot4Title:X])
Y=([Slot4Title:Y] + [Slot4Title:H] + ([Slot4BoundingBox:H] - [Slot4Title:H]) / 2)
W=([Slot4Title:W] - #ButtonHeight#)
H=#ButtonHeight#
StringAlign=LeftCenter
StringStyle=Bold
FontSize=16
AntiAlias=1
DynamicVariables=1
Group=Slot4|Slot4Settings|Slot4SettingSpinner

