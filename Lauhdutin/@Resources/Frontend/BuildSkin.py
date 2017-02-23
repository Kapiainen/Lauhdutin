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

    with open(os.path.join(ResourcePath, "Frontend", "GameSlots.inc"),
              "w") as f:
        # Variables
        if settings.get("orientation", "vertical") == "vertical":
            f.write("""[Variables]
ToolbarWidth=%s
SkinMaxWidth=%s
SkinMaxHeight=%s""" % (settings.get("slot_width", 418), settings.get("slot_width", 418), int(settings.get("slot_height", 195)) * int(settings.get("slot_count", 6))))
        else:
            f.write("""[Variables]
ToolbarWidth=%s
SkinMaxWidth=%s
SkinMaxHeight=%s""" % (int(settings.get("slot_width", 418)) *
                      int(settings.get("slot_count", 6)), int(settings.get("slot_width", 418)) * int(settings.get("slot_count", 6)), settings.get("slot_height", 195)))
        f.write("""
SlotCount=%s
SlotWidth=%s
SlotHeight=%s
SlotBackgroundColor=%s
SlotTextColor=%s
""" % (settings.get("slot_count", 6), settings.get("slot_width", 418),
       settings.get("slot_height", 195), settings.get("slot_background_color",
                                                      "0,0,0,196"),
       settings.get("slot_text_color", "255,255,255,255")))
        i = 1
        while i <= int(settings.get("slot_count", 6)):
            f.write("""SlotImage%s=
SlotName%s=
SlotHighlightMessage%s=
""" % (i, i, i))
            i += 1

        # Slot background
        f.write("""
[SlotBackground]
Meter=Image
X=0
Y=0
SolidColor=#SlotBackgroundColor#""")
        if settings.get("orientation", "vertical") == "vertical":
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
        while i <= int(settings.get("slot_count", 6)):
            # Text for game title
            f.write("""
[SlotText%s]
Meter=String""" % i)

            if settings.get("orientation", "vertical") == "vertical":
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
            if settings.get("orientation", "vertical") == "vertical":
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
            if settings.get("orientation", "vertical") == "vertical":
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
