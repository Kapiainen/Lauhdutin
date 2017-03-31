# Python environment
import sys, os, subprocess, json

try:
    RAINMETERPATH = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
    RESOURCEPATH = sys.argv[2][:-1]
    CONFIG = sys.argv[3][:-1]
    CURRENTFILE = sys.argv[4][:-1]

    def read_json(a_path):
        if os.path.isfile(a_path):
            with open(a_path, encoding="utf-8") as f:
                return json.load(f)
        return None

    SETTINGS = read_json(os.path.join(RESOURCEPATH, "settings.json"))
    SLOT_WIDTH = int(SETTINGS.get("slot_width", 418))
    SLOT_HEIGHT = int(SETTINGS.get("slot_height", 195))
    SLOT_COUNT = int(SETTINGS.get("slot_count", 6))
    ORIENTATION = SETTINGS.get("orientation", "vertical")
    
    with open(os.path.join(RESOURCEPATH, "Frontend", "GameSlots.inc"), "w") as file:
        # Variables section
        contents = ["[Variables]"]
        if ORIENTATION == "vertical":
            contents.extend([
                "ToolbarWidth=%s" % SLOT_WIDTH,
                "SkinMaxWidth=%s" % SLOT_WIDTH,
                "SkinMaxHeight=%s" % int(SLOT_HEIGHT * SLOT_COUNT)
            ])
        else:
            contents.extend([
                "ToolbarWidth=%s" % int(SLOT_WIDTH * SLOT_COUNT),
                "SkinMaxWidth=%s" % int(SLOT_WIDTH * SLOT_COUNT),
                "SkinMaxHeight=%s" % SLOT_HEIGHT
            ])
        contents.extend([
            "SlotCount=%s" % SLOT_COUNT,
            "SlotWidth=%s" % SLOT_WIDTH,
            "SlotHeight=%s" % SLOT_HEIGHT,
            "SlotBackgroundColor=%s" % SETTINGS.get("slot_background_color", "0,0,0,196"),
            "SlotTextColor=%s" % SETTINGS.get("slot_text_color", "255,255,255,255")
        ])
        for i in range(1, SLOT_COUNT + 1):
            contents.extend([
                "SlotImage%s=" % i,
                "SlotName%s=" % i,
                "SlotHighlightMessage%s=" % i
            ])
        contents.append("\n")

        # Sliver of skin that triggers animation when the mouse hovers over it
        if ORIENTATION == "vertical":
            if SETTINGS.get("skin_slide_animation_direction", 0) == 1: # From the right
                contents.extend([
                    "[SkinEnabler]",
                    "Meter=Image",
                    "X=0",
                    "Y=0",
                    "W=1",
                    "H=%s" % int(SLOT_HEIGHT * SLOT_COUNT),
                    "SolidColor=0,0,0,1",
                    """MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(true)"]""",
                    "\n"
                ])
            elif SETTINGS.get("skin_slide_animation_direction", 0) == 2: # From the right
                contents.extend([
                    "[SkinEnabler]",
                    "Meter=Image",
                    "X=%s" % int(SLOT_WIDTH - 1),
                    "Y=0",
                    "W=1",
                    "H=%s" % int(SLOT_HEIGHT * SLOT_COUNT),
                    "SolidColor=0,0,0,1",
                    """MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(true)"]""",
                    "\n"
                ])
        else:
            if SETTINGS.get("skin_slide_animation_direction", 0) == 3: # From above
                contents.extend([
                    "[SkinEnabler]",
                    "Meter=Image",
                    "X=0",
                    "Y=0",
                    "W=%s" % int(SLOT_WIDTH * SLOT_COUNT),
                    "H=1",
                    "SolidColor=0,0,0,1",
                    """MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(true)"]""",
                    "\n"
                ])
            elif SETTINGS.get("skin_slide_animation_direction", 0) == 4: # From below
                contents.extend([
                    "[SkinEnabler]",
                    "Meter=Image",
                    "X=0",
                    "Y=%s" % int(SLOT_HEIGHT - 1),
                    "W=%s" % int(SLOT_WIDTH * SLOT_COUNT),
                    "H=1",
                    "SolidColor=0,0,0,1",
                    """MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(true)"]""",
                    "\n"
                ])

        # Slots background
        contents.extend([
            "[SlotsBackground]",
            "Meter=Image",
            "X=0",
            "Y=0",
            "SolidColor=#SlotBackgroundColor#"
        ])
        if ORIENTATION == "vertical":
            contents.extend([
                "W=%s" % SLOT_WIDTH,
                "H=%s" % int(SLOT_COUNT * SLOT_HEIGHT)
            ])
        else:
            contents.extend([
                "W=%s" % int(SLOT_COUNT * SLOT_WIDTH),
                "H=%s" % SLOT_HEIGHT
            ])
        contents.append("\n")

        # Slots
        for i in range(1, SLOT_COUNT + 1):
            # Game title
            contents.extend([
                "[SlotText%s]" % i,
                "Meter=String",
            ])
            if ORIENTATION == "vertical":
                contents.extend([
                    "X=%s" % int(SLOT_WIDTH / 2),
                    "Y=%s" % int((i - 1) * SLOT_HEIGHT + SLOT_HEIGHT / 2)
                ])
            else:
                contents.extend([
                    "X=%s" % int((i - 1) * SLOT_WIDTH + SLOT_WIDTH / 2),
                    "Y=%s" % int(SLOT_HEIGHT / 2)
                ])
            contents.extend([
                "W=%s" % SLOT_WIDTH,
                "H=%s" % SLOT_HEIGHT,
                "Text=#SlotName%s#" % i,
                "FontFace=Arial", 
                "FontSize=%s" % int(SLOT_WIDTH / 15),
                "FontColor=%s" % SETTINGS.get("slot_text_color", "255,255,255,255"),
                "StringAlign=CenterCenter",
                "StringEffect=Shadow",
                "ClipString=1",
                "AntiAlias=1",
                "DynamicVariables=1",
                "Group=Slots",
                "\n"
            ])

            # Game banner
            contents.extend([
                "[SlotBanner%s]" % i,
                "Meter=Image",
                "ImageName=#SlotImage%s#" % i
            ])
            if ORIENTATION == "vertical":
                contents.extend([
                    "X=0",
                    "Y=%s" % int((i - 1) * SLOT_HEIGHT)
                ])
            else:
                contents.extend([
                    "X=%s" % int((i - 1) * SLOT_WIDTH),
                    "Y=0"
                ])
            contents.extend([
                "W=%s" % SLOT_WIDTH,
                "H=%s" % SLOT_HEIGHT,
                "SolidColor=0,0,0,1",
                "PreserveAspectRatio=2",
                "DynamicVariables=1",
                """MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(%s)"]""" % i,
                """MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(%s)"]""" % i,
                """MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(%s)"]""" % i,
                """LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(%s)"]""" % i,
                "Group=Slots",
                "\n"
            ])

#            # Game highlight
#            contents.extend([
#                "[SlotHighlightBackground%s]" % i,
#                "Meter=Image"
#            ])
#            if ORIENTATION == "vertical":
#                contents.extend([
#                    "X=0",
#                    "Y=%s" % (i - 1) * SLOT_HEIGHT
#                ])
#            else:
#                contents.extend([
#                    "X=%s" % (i - 1) * SLOT_WIDTH,
#                    "Y=0"
#                ])
#            contents.extend([
#                "W=%s" % SLOT_WIDTH,
#                "H=%s" % SLOT_HEIGHT,
#                "SolidColor=0,0,0,160",
#                "PreserveAspectRatio=2",
#                "DynamicVariables=1",
#                "Group=SlotHighlight%s | SlotHighlights" % i,
#                ""
#            ])
#            contents.extend([
#                "[SlotHighlight%s]" % i,
#                "Meter=Image",
#                "ImageName=",
#                "X=0r",
#                "Y=0r",
#                "W=%s" % SLOT_WIDTH,
#                "H=%s" % SLOT_HEIGHT,
#                "SolidColor=0,0,0,1",
#                "PreserveAspectRatio=2",
#                "DynamicVariables=1",
#                "Group=SlotHighlight%s | SlotHighlights" % i,
#                ""
#            ])
#            contents.extend([
#                "[SlotHighlightText%s]" % i,
#                "Meter=String",
#                "X=%sr" % SLOT_WIDTH / 2,
#                "Y=%sr" % SLOT_HEIGHT / 2,
#                "W=%s" % SLOT_WIDTH,
#                "H=%s" % SLOT_HEIGHT,
#                "Text=#SlotHighlightMessage%s#" % i,
#                "FontFace=Arial",
#                "FontSize=%s" % SLOT_WIDTH / 25,
#                "FontColor=%s" % SETTINGS.get("slot_text_color", "255,255,255,255"),
#                "StringAlign=CenterCenter",
#                "StringEffect=Shadow",
#                "ClipString=1",
#                "AntiAlias=1",
#                "DynamicVariables=1",
#                "Group=SlotHighlight%s | SlotHighlights" % i,
#                ""
#            ])

        # Game highlight
        contents.extend([
            "[SlotHighlightBackground]",
            "Meter=Image",
            "X=0",
            "Y=0",
            "W=%s" % SLOT_WIDTH,
            "H=%s" % SLOT_HEIGHT,
            "SolidColor=0,0,0,160",
            "PreserveAspectRatio=2",
            "DynamicVariables=1",
            "Group=SlotHighlight",
            "\n"
            "[SlotHighlight]",
            "Meter=Image",
            "ImageName=",
            "X=0r",
            "Y=0r",
            "W=%s" % SLOT_WIDTH,
            "H=%s" % SLOT_HEIGHT,
            "SolidColor=0,0,0,1",
            "PreserveAspectRatio=2",
            "DynamicVariables=1",
            "Group=SlotHighlight",
            "\n"
            "[SlotHighlightText]",
            "Meter=String",
            "X=%sr" % int(SLOT_WIDTH / 2),
            "Y=%sr" % int(SLOT_HEIGHT / 2),
            "W=%s" % SLOT_WIDTH,
            "H=%s" % SLOT_HEIGHT,
            "Text=#SlotHighlightMessage#",
            "FontFace=Arial",
            "FontSize=%s" % int(SLOT_WIDTH / 25),
            "FontColor=%s" % SETTINGS.get("slot_text_color", "255,255,255,255"),
            "StringAlign=CenterCenter",
            "StringEffect=Shadow",
            "ClipString=1",
            "AntiAlias=1",
            "DynamicVariables=1",
            "Group=SlotHighlight",
            "\n"
        ])

        contents = "\n".join(contents)
        file.write(contents)

    if CURRENTFILE != "Main.ini":
        subprocess.call(
            [RAINMETERPATH, "!ActivateConfig", CONFIG, "Main.ini"], shell=False)
    else:
        subprocess.call([RAINMETERPATH, "!Refresh", CONFIG], shell=False)
except:
    import traceback
    traceback.print_exc()
input()
