[Variables]
ToolbarWidth=320
SkinMaxWidth=320
SkinMaxHeight=150
SlotWidth=320
SlotHeight=150
SlotBackgroundColor=0,0,0,255
SlotTextColor=255,255,255,255
ToolbarBackgroundColor=0,0,0,196


[SlotsBackground]
Meter=Image
X=0
Y=0
W=#SkinMaxWidth#
H=#SkinMaxHeight#
SolidColor=#SlotBackgroundColor#
MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(false)"]


[SlotAnimation]
Meter=Image
ImageName=
X=-1
Y=-1
W=0
H=0
SolidColor=0,0,0,1
PreserveAspectRatio=2


[CutoutBackground]
Meter=Shape
X=0
Y=0
Shape=Rectangle 0,0,#SkinMaxWidth#,#SkinMaxHeight# | Fill Color #SlotBackgroundColor#
Shape2=Rectangle 0,0,0,0
Shape3=Combine Shape | XOR Shape2


[SlotText1]
Meter=String
X=160r
Y=75r
W=320
H=150
Text=
FontFace=Arial
FontSize=21
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
X=-160r
Y=-75r
W=320
H=150
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
W=320
H=150
SolidColor=0,0,0,160
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight

[SlotHighlight]
Meter=Image
ImageName=
X=0r
Y=0r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight

[SlotHighlightText]
Meter=String
X=160r
Y=75r
W=320
H=150
Text=
FontFace=Arial
FontSize=12
FontColor=255,255,255,255
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=SlotHighlight

