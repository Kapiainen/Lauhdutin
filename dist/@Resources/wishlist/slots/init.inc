[Variables]
SkinWidth=320
SkinHeight=1200
SlotWidth=320
SlotHeight=150
SlotOverlayTextSize=12

[SkinEnabler]
Meter=Image
SolidColor=0,0,0,1
X=0
Y=0
W=1
H=1200
MouseOverAction=[!CommandMeasure "Script" "OnMouseOver()"]
MouseLeaveAction=[!CommandMeasure "Script" "OnMouseLeaveEnabler()"]

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
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 225)
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
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 150)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot2

[Slot3Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 375)
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
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 300)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot3

[Slot4Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 525)
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
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 450)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot4

[Slot5Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 675)
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
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(5)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(5)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(5)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(5)"]
Group=Slots|Slot5

[Slot5Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 600)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot5

[Slot6Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 825)
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
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(6)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(6)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(6)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(6)"]
Group=Slots|Slot6

[Slot6Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 750)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot6

[Slot7Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 975)
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
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(7)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(7)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(7)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(7)"]
Group=Slots|Slot7

[Slot7Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 900)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot7

[Slot8Text]
Meter=String
Text=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 160)
Y=([SlotsBackground:Y] + 1125)
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
LeftMouseUpAction=[!CommandMeasure "Script" "OnLeftClickSlot(8)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnMiddleClickSlot(8)"]
MouseOverAction=[!CommandMeasure "Script" "OnHoverSlot(8)"]
MouseLeaveAction=[!CommandMeasure "Script" "OnLeaveSlot(8)"]
Group=Slots|Slot8

[Slot8Image]
Meter=Image
ImageName=
SolidColor=0,0,0,1
X=([SlotsBackground:X] + 0)
Y=([SlotsBackground:Y] + 1050)
W=320
H=150
PreserveAspectRatio=2
DynamicVariables=1
Group=Slots|Slot8

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
