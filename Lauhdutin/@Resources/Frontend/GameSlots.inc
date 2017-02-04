[Variables]
ToolbarWidth=460
SlotCount=1
SlotWidth=460
SlotHeight=215
SlotBackgroundColor=0,0,0,196
SlotTextColor=255,255,255,255
SlotPath1=
SlotImage1=
SlotName1=

[SlotBackground]
Meter=Image
X=0
Y=0
SolidColor=#SlotBackgroundColor#
W=#SlotWidth#
H=(#SlotCount#*#SlotHeight#)

[SlotText1]
Meter=String
X=(#SlotWidth#/2)
Y=(0*#SlotHeight#+#SlotHeight#/2)
W=#SlotWidth#
H=#SlotHeight#
Text=#SlotName1#
FontFace=Arial
FontSize=(#SlotWidth#/15)
FontColor=#SlotTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=Slots

[SlotBanner1]
Meter=Image
ImageName=#SlotImage1#
X=0
Y=(0*#SlotHeight#)
W=#SlotWidth#
H=#SlotHeight#
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "Launch('#SlotPath1#')"]
Group=Slots