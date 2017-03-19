# Python environment
import sys, os, subprocess, json

try:
    RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
    ResourcePath = sys.argv[2][:-1]
    Config = sys.argv[3][:-1]
    CurrentFile = sys.argv[4][:-1]

    def read_json(a_path):
        if os.path.isfile(a_path):
            with open(a_path, encoding="utf-8") as f:
                return json.load(f)
        return None

    settings = read_json(os.path.join(ResourcePath, "settings.json"))
    SLOT_WIDTH = int(settings.get("slot_width", 418))
    SLOT_HEIGHT = int(settings.get("slot_height", 195))
    SLOT_COUNT = int(settings.get("slot_count", 6))
    ORIENTATION = settings.get("orientation", "vertical")

    with open(os.path.join(ResourcePath, "Frontend", "GameSlots.inc"),
              "w") as f:
        # Variables
        if ORIENTATION == "vertical":
            f.write("""[Variables]
ToolbarWidth=%s
SkinMaxWidth=%s
SkinMaxHeight=%s""" % (SLOT_WIDTH, SLOT_WIDTH, SLOT_HEIGHT * SLOT_COUNT))
        else:
            f.write("""[Variables]
ToolbarWidth=%s
SkinMaxWidth=%s
SkinMaxHeight=%s""" % (SLOT_WIDTH *
                      SLOT_COUNT, SLOT_WIDTH * SLOT_COUNT, SLOT_HEIGHT))
        f.write("""
SlotCount=%s
SlotWidth=%s
SlotHeight=%s
SlotBackgroundColor=%s
SlotTextColor=%s
""" % (
        SLOT_COUNT,
        SLOT_WIDTH,
        SLOT_HEIGHT,
        settings.get("slot_background_color", "0,0,0,196"),
        settings.get("slot_text_color", "255,255,255,255")
    )
)
        i = 1
        while i <= SLOT_COUNT:
            f.write("""SlotImage%s=
SlotName%s=
SlotHighlightMessage%s=
""" % (i, i, i))
            i += 1

        f.write("""
[ClickAnimation]
Measure=Plugin
Plugin=ActionTimer
ActionList1=ResetVertical | Wait #FrameInterval# | Shrink1Vertical | Wait #FrameInterval# | Shrink2Vertical | Wait #FrameInterval# | Shrink3Vertical | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetVertical | Launch
ActionList2=ResetVertical | Wait #FrameInterval# | ShiftLeft1 | Wait #FrameInterval# | ShiftLeft2 | Wait #FrameInterval# | ShiftLeft3 | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetVertical | Launch
ActionList3=ResetVertical | Wait #FrameInterval# | ShiftRight1 | Wait #FrameInterval# | ShiftRight2 | Wait #FrameInterval# | ShiftRight3 | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetVertical | Launch
ActionList4=ResetHorizontal | Wait #FrameInterval# | Shrink1Horizontal | Wait #FrameInterval# | Shrink2Horizontal | Wait #FrameInterval# | Shrink3Horizontal | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetHorizontal | Launch
ActionList5=ResetHorizontal | Wait #FrameInterval# | ShiftUp1 | Wait #FrameInterval# | ShiftUp2 | Wait #FrameInterval# | ShiftUp3 | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetHorizontal | Launch
ActionList6=ResetHorizontal | Wait #FrameInterval# | ShiftDown1 | Wait #FrameInterval# | ShiftDown2 | Wait #FrameInterval# | ShiftDown3 | Wait #FrameInterval# | BlankSlot | Wait #FrameInterval# | ResetHorizontal | Launch
Launch=[!CommandMeasure LauhdutinScript "Launch('#SlotToAnimate#')"]
BlankSlot=[!SetVariable "SlotImage#SlotToAnimate#" ""][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""")

        f.write("""
ResetVertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "((#SlotToAnimate# - 1) * %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ResetHorizontal=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!SetOption "SlotBanner#SlotToAnimate#" "X" "((#SlotToAnimate# - 1) * %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        SLOT_HEIGHT, SLOT_WIDTH, SLOT_HEIGHT,
        SLOT_WIDTH, SLOT_WIDTH, SLOT_HEIGHT
    )
)

        ShrinkLevel1Width = SLOT_WIDTH / 1.8
        ShrinkLevel2Width = SLOT_WIDTH / 4
        ShrinkLevel3Width = SLOT_WIDTH / 20
        ShrinkLevel1Height = SLOT_HEIGHT / 1.8
        ShrinkLevel2Height = SLOT_HEIGHT / 4
        ShrinkLevel3Height = SLOT_HEIGHT / 20
        f.write("""
Shrink1Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink2Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink3Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        ((SLOT_WIDTH - ShrinkLevel1Width) / 2), SLOT_HEIGHT, ((SLOT_HEIGHT - ShrinkLevel1Height) / 2), (ShrinkLevel1Width), (ShrinkLevel1Height),
        ((SLOT_WIDTH - ShrinkLevel2Width) / 2), SLOT_HEIGHT, ((SLOT_HEIGHT - ShrinkLevel2Height) / 2), (ShrinkLevel2Width), (ShrinkLevel2Height),
        ((SLOT_WIDTH - ShrinkLevel3Width) / 2), SLOT_HEIGHT, ((SLOT_HEIGHT - ShrinkLevel3Height) / 2), (ShrinkLevel3Width), (ShrinkLevel3Height)
    )
)

        f.write("""
Shrink1Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink2Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink3Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * %s) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        SLOT_WIDTH, ((SLOT_WIDTH - ShrinkLevel1Width) / 2), ((SLOT_HEIGHT - ShrinkLevel1Height) / 2), (ShrinkLevel1Width), (ShrinkLevel1Height),
        SLOT_WIDTH, ((SLOT_WIDTH - ShrinkLevel2Width) / 2), ((SLOT_HEIGHT - ShrinkLevel2Height) / 2), (ShrinkLevel2Width), (ShrinkLevel2Height),
        SLOT_WIDTH, ((SLOT_WIDTH - ShrinkLevel3Width) / 2), ((SLOT_HEIGHT - ShrinkLevel3Height) / 2), (ShrinkLevel3Width), (ShrinkLevel3Height)
    )
)

        ShiftLevel1Vertical = (SLOT_WIDTH / 20.0)
        ShiftLevel2Vertical = (SLOT_WIDTH / 4.0)
        ShiftLevel3Vertical = (SLOT_WIDTH / 1.8)
        ShiftLevel1Horizontal = (SLOT_HEIGHT / 20.0)
        ShiftLevel2Horizontal = (SLOT_HEIGHT / 4.0)
        ShiftLevel3Horizontal = (SLOT_HEIGHT / 1.8)
        f.write("""
ShiftLeft1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftLeft2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftLeft3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - %s)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
DynamicVariables=1
""" %
    (
        ShiftLevel1Vertical,
        ShiftLevel2Vertical,
        ShiftLevel3Vertical,
        ShiftLevel1Vertical,
        ShiftLevel2Vertical,
        ShiftLevel3Vertical,
        ShiftLevel1Horizontal,
        ShiftLevel2Horizontal,
        ShiftLevel3Horizontal,
        ShiftLevel1Horizontal,
        ShiftLevel2Horizontal,
        ShiftLevel3Horizontal
    )
)

        f.write("""
[HoverOnAnimation]
Measure=Plugin
Plugin=ActionTimer
DynamicVariables=1
ActionList1=ZoomIn1Vertical | Wait #FrameInterval# | ZoomIn2Vertical | Wait #FrameInterval# | ZoomIn3Vertical
ActionList2=ZoomIn1Horizontal | Wait #FrameInterval# | ZoomIn2Horizontal | Wait #FrameInterval# | ZoomIn3Horizontal
ActionList3=Jiggle1 | Wait #FrameInterval# | Jiggle2 | Wait #FrameInterval# | Jiggle3 | Wait #FrameInterval# | Jiggle2
ActionList4=Shake1 | Wait #FrameInterval# | Shake2 | Wait #FrameInterval# | Shake3 | Wait #FrameInterval# | Shake2""")

        f.write("""
ZoomIn1Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn2Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn3Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        (SLOT_WIDTH / 100 * 105), (0 - ((SLOT_WIDTH / 100 * 105) - SLOT_WIDTH) / 2),
        (SLOT_WIDTH / 100 * 110), (0 - ((SLOT_WIDTH / 100 * 110) - SLOT_WIDTH) / 2),
        (SLOT_WIDTH / 100 * 115), (0 - ((SLOT_WIDTH / 100 * 115) - SLOT_WIDTH) / 2)
    )
)

        f.write("""
ZoomIn1Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn2Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn3Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Jiggle1=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "2"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Jiggle2=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Jiggle3=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "-2"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        (SLOT_HEIGHT / 100 * 105), (0 - ((SLOT_HEIGHT / 100 * 105) - SLOT_HEIGHT) / 2),
        (SLOT_HEIGHT / 100 * 110), (0 - ((SLOT_HEIGHT / 100 * 110) - SLOT_HEIGHT) / 2),
        (SLOT_HEIGHT / 100 * 115), (0 - ((SLOT_HEIGHT / 100 * 115) - SLOT_HEIGHT) / 2)
    )
)

        if ORIENTATION == "vertical":
            f.write("""
Shake1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "-5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
""")
        else:
            f.write("""
Shake1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "-5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
""")

        f.write("""
[HoverOffAnimation]
Measure=Plugin
Plugin=ActionTimer
ActionList1=ResetVertical
ActionList2=ResetHorizontal
ResetVertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "((#SlotToAnimate# - 1) * %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ResetHorizontal=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!SetOption "SlotBanner#SlotToAnimate#" "X" "((#SlotToAnimate# - 1) * %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
DynamicVariables=1
""" % (
        SLOT_HEIGHT, SLOT_WIDTH, SLOT_HEIGHT,
        SLOT_WIDTH, SLOT_WIDTH, SLOT_HEIGHT
    )
)

        # Skin showing sliver
        if ORIENTATION == "vertical":
            f.write("""
[SkinEnabler]
Meter=Image
X=0
Y=0
W=1
H=%s
SolidColor=0,0,0,1
MouseOverAction=[!CommandMeasure "LauhdutinScript" "SlideSkinIn()"]
""" % (
        SLOT_HEIGHT * SLOT_COUNT
    )
)
        else:
            f.write("""
[SkinEnabler]
Meter=Image
X=0
Y=0
W=%s
H=1
SolidColor=0,0,0,1
MouseOverAction=[!CommandMeasure "LauhdutinScript" "SlideSkinIn()"]
""" % (
        SLOT_WIDTH * SLOT_COUNT
    )
)

        # Slot background
        f.write("""
[SlotBackground]
Meter=Image
X=0
Y=0
SolidColor=#SlotBackgroundColor#""")
        if ORIENTATION == "vertical":
            f.write("""
W=%s
H=%s
""" % (
        SLOT_WIDTH,
        SLOT_COUNT * SLOT_HEIGHT
    )
)
        else:
            f.write("""
W=%s
H=%s
""" % (
        SLOT_COUNT * SLOT_WIDTH,
        SLOT_HEIGHT
    )
)

        # Slots
        i = 1
        while i <= SLOT_COUNT:
            # Text for game title
            f.write("""
[SlotText%s]
Meter=String""" % i)

            if ORIENTATION == "vertical":
                f.write("""
X=%s
Y=%s""" % (
        SLOT_WIDTH / 2,
        (i - 1) * SLOT_HEIGHT + SLOT_HEIGHT / 2
    )
)
            else:
                f.write("""
X=%s
Y=%s""" % (
        (i - 1) * SLOT_WIDTH + SLOT_WIDTH / 2,
        SLOT_HEIGHT / 2
    )
)

            f.write("""
W=%s
H=%s
Text=#SlotName%s#
FontFace=Arial
FontSize=%s
FontColor=%s
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=Slots
""" % (
        SLOT_WIDTH,
        SLOT_HEIGHT,
        i,
        SLOT_WIDTH / 15,
        settings.get("slot_text_color", "255,255,255,255")
    )
)

            # Game banner
            f.write("""
[SlotBanner%s]
Meter=Image
ImageName=#SlotImage%s#""" % (i, i))
            if ORIENTATION == "vertical":
                f.write("""
X=0
Y=%s""" % (
        (i - 1) * SLOT_HEIGHT
    )
)
            else:
                f.write("""
X=%s
Y=0""" % (
        (i - 1) * SLOT_WIDTH
    )
)

            f.write("""
W=%s
H=%s
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
MouseOverAction=[!CommandMeasure LauhdutinScript "Highlight('%s')"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "Unhighlight('%s')"]
""" % (
        SLOT_WIDTH,
        SLOT_HEIGHT,
        i,
        i
    )
)

            if settings.get("click_animation", 1) > 0:
                f.write("""LeftMouseUpAction=[!SetVariable "SlotToAnimate" "%s"][!UpdateMeasure "ClickAnimation"][!CommandMeasure "ClickAnimation" "Execute %s"]
Group=Slots
""" % (i, settings.get("click_animation", 1)))
            else:
                f.write("""LeftMouseUpAction=[!CommandMeasure LauhdutinScript "Launch('%s')"]
Group=Slots
""" % i)

            # Game highlight
            f.write("""
[SlotHighlightBackground%s]
Meter=Image""" % i)
            if ORIENTATION == "vertical":
                f.write("""
X=0
Y=%s""" % (
        (i - 1) * SLOT_HEIGHT
    )
)
            else:
                f.write("""
X=%s
Y=0""" % (
        (i - 1) * SLOT_WIDTH
    )
)

            f.write("""
W=%s
H=%s
SolidColor=0,0,0,160
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight%s
""" % (
        SLOT_WIDTH,
        SLOT_HEIGHT,
        i
    )
)

            f.write("""
[SlotHighlight%s]
Meter=Image
ImageName=
X=0r
Y=0r
W=%s
H=%s
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight%s
""" % (
        i,
        SLOT_WIDTH,
        SLOT_HEIGHT,
        i
    )
)

            f.write("""
[SlotHighlightText%s]
Meter=String
X=%sr
Y=%sr
W=%s
H=%s
Text=#SlotHighlightMessage%s#
FontFace=Arial
FontSize=%s
FontColor=%s
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=SlotHighlight%s
""" % (
        i,
        SLOT_WIDTH / 2,
        SLOT_HEIGHT / 2,
        SLOT_WIDTH,
        SLOT_HEIGHT,
        i,
        SLOT_WIDTH / 25,
        settings.get("slot_text_color", "255,255,255,255"),
        i
    )
)
            i += 1

    if CurrentFile != "Main.ini":
        subprocess.call(
            [RainmeterPath, "!ActivateConfig", Config, "Main.ini"], shell=False)
    else:
        subprocess.call([RainmeterPath, "!Refresh", Config], shell=False)
except:
    import traceback
    traceback.print_exc()
    input()
