[Variables]
ToolbarWidth=1920
SkinMaxWidth=1920
SkinMaxHeight=150
SlotWidth=320
SlotHeight=150
SlotBackgroundColor=0,0,0,255
SlotTextColor=255,255,255,255
ToolbarBackgroundColor=0,0,0,196


[SkinEnabler]
Meter=Image
X=0
Y=0
W=1
H=#SkinMaxHeight#
SolidColor=0,0,0,1
MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(true)"]


[SlotsBackground]
Meter=Image
X=0
Y=0
W=#SkinMaxWidth#
H=#SkinMaxHeight#
SolidColor=#SlotBackgroundColor#


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
Shape=Rectangle 0,0,#SkinMaxWidth#,#SkinMaxHeight# | Fill Color #SlotBackgroundColor# | StrokeWidth 0
Shape2=Rectangle 0,0,0,0 | StrokeWidth 0
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


[SlotText2]
Meter=String
X=160R
Y=-75R
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


[SlotBanner2]
Meter=Image
ImageName=
X=-160r
Y=-75r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(2)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(2)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(2)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(2)"]
Group=Slots


[SlotText3]
Meter=String
X=160R
Y=-75R
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


[SlotBanner3]
Meter=Image
ImageName=
X=-160r
Y=-75r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(3)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(3)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(3)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(3)"]
Group=Slots


[SlotText4]
Meter=String
X=160R
Y=-75R
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


[SlotBanner4]
Meter=Image
ImageName=
X=-160r
Y=-75r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(4)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(4)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(4)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(4)"]
Group=Slots


[SlotText5]
Meter=String
X=160R
Y=-75R
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


[SlotBanner5]
Meter=Image
ImageName=
X=-160r
Y=-75r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(5)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(5)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(5)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(5)"]
Group=Slots


[SlotText6]
Meter=String
X=160R
Y=-75R
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


[SlotBanner6]
Meter=Image
ImageName=
X=-160r
Y=-75r
W=320
H=150
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(6)"]
MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(6)"]
MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(6)"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(6)"]
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

