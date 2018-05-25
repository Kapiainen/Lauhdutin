[Variables]
SkinWidth=1280
SkinHeight=150
SlotWidth=320
SlotHeight=150
SlotOverlayTextSize=12

[SlotsBackground]
Meter=Image
SolidColor=#SlotBackgroundColor#
X=0
Y=0
W=#SkinWidth#
H=#SkinHeight#
MouseScrollUpAction=[!CommandMeasure "Script" "OnScrollSlots(-1)"]
MouseScrollDownAction=[!CommandMeasure "Script" "OnScrollSlots(1)"]
MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]

[SlotAnimation]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=0
Y=0
W=0
H=0
PreserveAspectRatio=2

[SlotsBackgroundCutout]
Meter=Shape
X=([SlotsBackground:X])
Y=([SlotsBackground:Y])
Shape=Rectangle 0,0,#SkinWidth#,#SkinHeight# | Fill Color #SlotBackgroundColor# | StrokeWidth 0
Shape2=Rectangle 0,0,0,0 | StrokeWidth 0
Shape3=Combine Shape | XOR Shape2
DynamicVariables=1

[Slot1Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 75)
W=320
H=150
FontSize=#SlotOverlayTextSize#
FontColor=#SlotOverlayTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
StringStyle=Bold
AntiAlias=1
ClipString=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(1)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(1)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(1)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(1)"]
Group=Slots|Slot1

[Slot1Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 0)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot1

[Slot2Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 480)
Y=([SlotsBackground:Y] + 75)
W=320
H=150
FontSize=#SlotOverlayTextSize#
FontColor=#SlotOverlayTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
StringStyle=Bold
AntiAlias=1
ClipString=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(2)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(2)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(2)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(2)"]
Group=Slots|Slot2

[Slot2Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 320)
Y=([SlotsBackground:Y] + 0)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot2

[Slot3Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 800)
Y=([SlotsBackground:Y] + 75)
W=320
H=150
FontSize=#SlotOverlayTextSize#
FontColor=#SlotOverlayTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
StringStyle=Bold
AntiAlias=1
ClipString=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(3)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(3)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(3)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(3)"]
Group=Slots|Slot3

[Slot3Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 640)
Y=([SlotsBackground:Y] + 0)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot3

[Slot4Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 1120)
Y=([SlotsBackground:Y] + 75)
W=320
H=150
FontSize=#SlotOverlayTextSize#
FontColor=#SlotOverlayTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
StringStyle=Bold
AntiAlias=1
ClipString=1
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(4)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(4)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(4)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(4)"]
Group=Slots|Slot4

[Slot4Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 960)
Y=([SlotsBackground:Y] + 0)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot4

[SlotOverlayImage]
Meter=Image
ImageName=
SolidColor=#SlotOverlayColor#
X=0
Y=0
W=320
H=150
PreserveAspectRatio=2
Group=SlotOverlay

[SlotOverlayText]
Meter=String
Text=
X=160r
Y=75r
W=320
H=150
FontSize=#SlotOverlayTextSize#
FontColor=#SlotOverlayTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
StringStyle=Bold
AntiAlias=1
ClipString=1
Group=SlotOverlay
