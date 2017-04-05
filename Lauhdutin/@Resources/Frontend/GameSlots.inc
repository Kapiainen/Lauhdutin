[Variables]
ToolbarWidth=460
SkinMaxWidth=460
SkinMaxHeight=215
SlotWidth=460
SlotHeight=215
SlotBackgroundColor=0,0,0,196
SlotTextColor=255,255,255,255


[SlotsBackground]
Meter=Image
X=0
Y=0
SolidColor=#SlotBackgroundColor#
W=460
H=215


[SlotText1]
Meter=String
X=230
Y=107
W=460
H=215
Text=
FontFace=Arial
FontSize=30
FontColor=255,255,255,255
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=Slots


[SlotBanner1]
Meter=Image
ImageName=
X=0
Y=0
W=460
H=215
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(1)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(1)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(1)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(1)"]
Group=Slots


[SlotHighlightBackground]
Meter=Image
X=0
Y=0
W=460
H=215
SolidColor=0,0,0,160
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight

[SlotHighlight]
Meter=Image
ImageName=
X=0r
Y=0r
W=460
H=215
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight

[SlotHighlightText]
Meter=String
X=230r
Y=107r
W=460
H=215
Text=
FontFace=Arial
FontSize=18
FontColor=255,255,255,255
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=SlotHighlight

