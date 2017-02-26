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
""" % (SLOT_COUNT, SLOT_WIDTH,
       SLOT_HEIGHT, settings.get("slot_background_color",
                                                      "0,0,0,196"),
       settings.get("slot_text_color", "255,255,255,255")))
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
ResetVertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "((#SlotToAnimate# - 1) * #SlotHeight#)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "#SlotWidth#"][!SetOption "SlotBanner#SlotToAnimate#" "H" "#SlotHeight#"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ResetHorizontal=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!SetOption "SlotBanner#SlotToAnimate#" "X" "((#SlotToAnimate# - 1) * #SlotWidth#)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "#SlotWidth#"][!SetOption "SlotBanner#SlotToAnimate#" "H" "#SlotHeight#"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""")

        f.write("""
Shrink1Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * #SlotHeight#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink2Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * #SlotHeight#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink3Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "(((#SlotToAnimate# - 1) * #SlotHeight#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        int((SLOT_WIDTH - (SLOT_WIDTH / 1.8)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 1.8)) / 2), int(SLOT_WIDTH / 1.8), int(SLOT_HEIGHT / 1.8),
        int((SLOT_WIDTH - (SLOT_WIDTH / 4)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 4)) / 2), int(SLOT_WIDTH / 4), int(SLOT_HEIGHT / 4),
        int((SLOT_WIDTH - (SLOT_WIDTH / 20)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 20)) / 2), int(SLOT_WIDTH / 20), int(SLOT_HEIGHT / 20)
    )
)

        f.write("""
Shrink1Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * #SlotWidth#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink2Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * #SlotWidth#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shrink3Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(((#SlotToAnimate# - 1) * #SlotWidth#) + %s)"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        int((SLOT_WIDTH - (SLOT_WIDTH / 1.8)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 1.8)) / 2), int(SLOT_WIDTH / 1.8), int(SLOT_HEIGHT / 1.8),
        int((SLOT_WIDTH - (SLOT_WIDTH / 4)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 4)) / 2), int(SLOT_WIDTH / 4), int(SLOT_HEIGHT / 4),
        int((SLOT_WIDTH - (SLOT_WIDTH / 20)) / 2), int((SLOT_HEIGHT - (SLOT_HEIGHT / 20)) / 2), int(SLOT_WIDTH / 20), int(SLOT_HEIGHT / 20)
    )
)

        f.write("""
ShiftLeft1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - (#SlotWidth# / 20))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftLeft2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - (#SlotWidth# / 4))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftLeft3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(0 - (#SlotWidth# / 1.8))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(#SlotWidth# / 20)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(#SlotWidth# / 4)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftRight3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "(#SlotWidth# / 1.8)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - (#SlotWidth# / 20))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - (#SlotWidth# / 4))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftUp3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(0 - (#SlotWidth# / 1.8))"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(#SlotWidth# / 20)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(#SlotWidth# / 4)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ShiftDown3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "(#SlotWidth# / 1.8)"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
DynamicVariables=1
""")

        f.write("""
[HoverOnAnimation]
Measure=Plugin
Plugin=ActionTimer
DynamicVariables=1
ActionList1=ZoomIn1Vertical | Wait #FrameInterval# | ZoomIn2Vertical | Wait #FrameInterval# | ZoomIn3Vertical
ActionList2=ZoomIn1Horizontal | Wait #FrameInterval# | ZoomIn2Horizontal | Wait #FrameInterval# | ZoomIn3Horizontal
ActionList3=Twist1 | Wait #FrameInterval# | Twist2 | Wait #FrameInterval# | Twist3 | Wait #FrameInterval# | Twist2
ActionList4=Shake1 | Wait #FrameInterval# | Shake2 | Wait #FrameInterval# | Shake3 | Wait #FrameInterval# | Shake2""")

        f.write("""
ZoomIn1Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn2Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn3Vertical=[!SetOption "SlotBanner#SlotToAnimate#" "W" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "X" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        int(SLOT_WIDTH / 100 * 102), int(0 - ((SLOT_WIDTH / 100 * 102) - SLOT_WIDTH) / 2),
        int(SLOT_WIDTH / 100 * 104), int(0 - ((SLOT_WIDTH / 100 * 104) - SLOT_WIDTH) / 2),
        int(SLOT_WIDTH / 100 * 106), int(0 - ((SLOT_WIDTH / 100 * 106) - SLOT_WIDTH) / 2)
    )
)

        f.write("""
ZoomIn1Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn2Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ZoomIn3Horizontal=[!SetOption "SlotBanner#SlotToAnimate#" "H" "%s"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "%s"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Twist1=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "2"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Twist2=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Twist3=[!SetOption "SlotBanner#SlotToAnimate#" "ImageRotate" "-2"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""" %
    (
        int(SLOT_HEIGHT / 100 * 102), int(0 - ((SLOT_HEIGHT / 100 * 102) - SLOT_HEIGHT) / 2),
        int(SLOT_HEIGHT / 100 * 104), int(0 - ((SLOT_HEIGHT / 100 * 104) - SLOT_HEIGHT) / 2),
        int(SLOT_HEIGHT / 100 * 106), int(0 - ((SLOT_HEIGHT / 100 * 106) - SLOT_HEIGHT) / 2)
    )
)

        if ORIENTATION == "vertical":
            f.write("""
Shake1=[!SetOption "SlotBanner#SlotToAnimate#" "X" "-5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake2=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake3=[!SetOption "SlotBanner#SlotToAnimate#" "X" "5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""")
        else:
            f.write("""
Shake1=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "-5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake2=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
Shake3=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "5"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]""")

        f.write("""
[HoverOffAnimation]
Measure=Plugin
Plugin=ActionTimer
ActionList1=ResetVertical
ActionList2=ResetHorizontal
ResetVertical=[!SetOption "SlotBanner#SlotToAnimate#" "X" "0"][!SetOption "SlotBanner#SlotToAnimate#" "Y" "((#SlotToAnimate# - 1) * #SlotHeight#)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "#SlotWidth#"][!SetOption "SlotBanner#SlotToAnimate#" "H" "#SlotHeight#"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
ResetHorizontal=[!SetOption "SlotBanner#SlotToAnimate#" "Y" "0"][!SetOption "SlotBanner#SlotToAnimate#" "X" "((#SlotToAnimate# - 1) * #SlotWidth#)"][!SetOption "SlotBanner#SlotToAnimate#" "W" "#SlotWidth#"][!SetOption "SlotBanner#SlotToAnimate#" "H" "#SlotHeight#"][!UpdateMeter "SlotBanner#SlotToAnimate#"][!Redraw]
DynamicVariables=1
""")

        # Slot background
        f.write("""
[SlotBackground]
Meter=Image
X=0
Y=0
SolidColor=#SlotBackgroundColor#""")
        if ORIENTATION == "vertical":
            f.write("""
W=#SlotWidth#
H=(#SlotCount#*#SlotHeight#)
""")
        else:
            f.write("""
W=(#SlotCount#*#SlotWidth#)
H=#SlotHeight#
""")

        # Slots
        i = 1
        while i <= SLOT_COUNT:
            # Text for game title
            f.write("""
[SlotText%s]
Meter=String""" % i)

            if ORIENTATION == "vertical":
                f.write("""
X=(#SlotWidth#/2)
Y=(%s*#SlotHeight#+#SlotHeight#/2)""" % (i - 1))
            else:
                f.write("""
X=(%s*#SlotWidth#+#SlotWidth#/2)
Y=(#SlotHeight#/2)""" % (i - 1))

            f.write("""
W=#SlotWidth#
H=#SlotHeight#
Text=#SlotName%s#
FontFace=Arial
FontSize=(#SlotWidth#/15)
FontColor=#SlotTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=Slots
""" % i)

            # Game banner
            f.write("""
[SlotBanner%s]
Meter=Image
ImageName=#SlotImage%s#""" % (i, i))
            if ORIENTATION == "vertical":
                f.write("""
X=0
Y=(%s*#SlotHeight#)""" % (i - 1))
            else:
                f.write("""
X=(%s*#SlotWidth#)
Y=0""" % (i - 1))

            f.write("""
W=#SlotWidth#
H=#SlotHeight#
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
MouseOverAction=[!CommandMeasure LauhdutinScript "Highlight('%s')"]
MouseLeaveAction=[!CommandMeasure LauhdutinScript "Unhighlight('%s')"]
""" % (i, i))
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
Y=(%s*#SlotHeight#)""" % (i - 1))
            else:
                f.write("""
X=(%s*#SlotWidth#)
Y=0""" % (i - 1))
            f.write("""
W=#SlotWidth#
H=#SlotHeight#
SolidColor=0,0,0,160
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight%s

[SlotHighlight%s]
Meter=Image
ImageName=
X=0r
Y=0r
W=#SlotWidth#
H=#SlotHeight#
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
Group=SlotHighlight%s

[SlotHighlightText%s]
Meter=String
X=(#SlotWidth# / 2)r
Y=(#SlotHeight# / 2)r
W=#SlotWidth#
H=#SlotHeight#
Text=#SlotHighlightMessage%s#
FontFace=Arial
FontSize=(#SlotWidth#/25)
FontColor=#SlotTextColor#
StringAlign=CenterCenter
StringEffect=Shadow
ClipString=1
AntiAlias=1
DynamicVariables=1
Group=SlotHighlight%s
""" % (i, i, i, i, i, i))

            i += 1

    if CurrentFile != "Main.ini":
        subprocess.call(
            [RainmeterPath, "!ActivateConfig", Config, "Main.ini"], shell=True)
    else:
        subprocess.call([RainmeterPath, "!Refresh", Config], shell=True)
except:
    import traceback
    traceback.print_exc()
    input()
