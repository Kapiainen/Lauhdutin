[Variables]
ToolbarHeight=48

[ToolbarEnabler]
Meter=Image
SolidColor=0,0,0,1
X=0
Y=0
W=#SkinWidth#
H=1
DynamicVariables=1
MouseOverAction=[!CommandMeasure "Script" "OnMouseOverToolbar()"]

[ToolbarBackground]
Meter=Image
SolidColor=#ToolbarBackgroundColor#
X=0
Y=0
W=#SkinWidth#
H=#ToolbarHeight#
DynamicVariables=1
Group=Toolbar
LeftMouseUpAction=[]
MiddleMouseUpAction=[]
MouseLeaveAction=[!CommandMeasure "Script" "OnMouseLeaveToolbar()"]

[ToolbarSeparator1]
Meter=Image
SolidColor=#ToolbarSeparatorColor#
X=(#SkinWidth# / 3 - 1)
Y=([ToolbarBackground:Y] + 2)
W=2
H=(#ToolbarHeight# - 4)
DynamicVariables=1
Group=Toolbar

[ToolbarSeparator2]
Meter=Image
SolidColor=#ToolbarSeparatorColor#
X=(#SkinWidth# / 3 * 2 - 1)
Y=([ToolbarBackground:Y] + 2)
W=2
H=(#ToolbarHeight# - 4)
DynamicVariables=1
Group=Toolbar

[ToolbarSearch]
Meter=Image
SolidColor=0,0,0,1
ImageName=#@#main\gfx\toolbar_search.png
X=0
Y=[ToolbarBackground:Y]
W=(#SkinWidth# / 3)
H=#ToolbarHeight#
PreserveAspectRatio=1
DynamicVariables=1
Group=Toolbar
LeftMouseUpAction=[!CommandMeasure "Script" "OnToolbarSearch(false)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnToolbarSearch(true)"]
RightMouseUpAction=[!CommandMeasure "Script" "OnToolbarResetGames()"]

[ToolbarSort]
Meter=Image
SolidColor=0,0,0,1
ImageName=#@#main\gfx\toolbar_sort.png
X=(#SkinWidth# / 3)
Y=[ToolbarBackground:Y]
W=(#SkinWidth# / 3)
H=#ToolbarHeight#
PreserveAspectRatio=1
DynamicVariables=1
Group=Toolbar
LeftMouseUpAction=[!CommandMeasure "Script" "OnToolbarSort(false)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnToolbarSort(true)"]
RightMouseUpAction=[!CommandMeasure "Script" "OnToolbarReverseOrder()"]

[ToolbarFilter]
Meter=Image
SolidColor=0,0,0,1
ImageName=#@#main\gfx\toolbar_filter.png
X=(#SkinWidth# / 3 * 2)
Y=[ToolbarBackground:Y]
W=(#SkinWidth# / 3)
H=#ToolbarHeight#
PreserveAspectRatio=1
DynamicVariables=1
Group=Toolbar
LeftMouseUpAction=[!CommandMeasure "Script" "OnToolbarFilter(false)"]
MiddleMouseUpAction=[!CommandMeasure "Script" "OnToolbarFilter(true)"]
RightMouseUpAction=[!CommandMeasure "Script" "OnToolbarResetGames()"]
