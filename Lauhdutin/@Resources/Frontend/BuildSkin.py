# Python environment
import sys, os, subprocess, json, math

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
    SLOT_WIDTH = int(SETTINGS.get("slot_width", 321))
    SLOT_HEIGHT = int(SETTINGS.get("slot_height", 150))
    SLOT_COUNT = int(SETTINGS.get("slot_count", 8))
    SLOT_ROWS_COLUMNS = int(SETTINGS.get("slot_rows_columns", 1))
    SLOT_COUNT_PER_ROW_COLUMN = int(SETTINGS.get("slot_count_per_row_column", 8))
    ORIENTATION = SETTINGS.get("orientation", "vertical").lower()
    
    with open(os.path.join(RESOURCEPATH, "Frontend", "GameSlots.inc"), "w") as file:
        # Variables section
        contents = ["[Variables]"]
        if ORIENTATION == "vertical":
            contents.extend([
                "ToolbarWidth=%s" % int(SLOT_WIDTH * SLOT_ROWS_COLUMNS),
                "SkinMaxWidth=%s" % int(SLOT_WIDTH * SLOT_ROWS_COLUMNS),
                "SkinMaxHeight=%s" % int(SLOT_HEIGHT * SLOT_COUNT_PER_ROW_COLUMN)
            ])
        else:
            contents.extend([
                "ToolbarWidth=%s" % int(SLOT_WIDTH * SLOT_COUNT_PER_ROW_COLUMN),
                "SkinMaxWidth=%s" % int(SLOT_WIDTH * SLOT_COUNT_PER_ROW_COLUMN),
                "SkinMaxHeight=%s" % int(SLOT_HEIGHT * SLOT_ROWS_COLUMNS)
            ])
        contents.extend([
            "SlotWidth=%s" % SLOT_WIDTH,
            "SlotHeight=%s" % SLOT_HEIGHT,
            "SlotBackgroundColor=0,0,0,255",
            "SlotTextColor=255,255,255,255",
            "ToolbarBackgroundColor=0,0,0,196"
        ])
        contents.append("\n")

        # Sliver of skin that triggers animation when the mouse hovers over it
        SKIN_ANIMATION = SETTINGS.get("skin_slide_animation_direction", 0)
        if SKIN_ANIMATION > 0:
            contents.extend([
                "[SkinEnabler]",
                "Meter=Image",
            ])
            if SKIN_ANIMATION == 1: # From the left
                contents.extend([
                    "X=0",
                    "Y=0",
                    "W=1",
                    "H=#SkinMaxHeight#"
                ])
            elif SKIN_ANIMATION == 2: # From the right
                contents.extend([
                    "X=(#SkinMaxWidth# - 1)",
                    "Y=0",
                    "W=1",
                    "H=#SkinMaxHeight#"
                ])
            elif SKIN_ANIMATION == 3: # From above
                contents.extend([
                    "X=0",
                    "Y=0",
                    "W=#SkinMaxWidth#",
                    "H=1"
                ])
            elif SKIN_ANIMATION == 4: # From below
                contents.extend([
                    "X=0",
                    "Y=(#SkinMaxHeight# - 1)",
                    "W=#SkinMaxWidth#",
                    "H=1"
                ])
            contents.extend([
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
            "W=#SkinMaxWidth#", 
            "H=#SkinMaxHeight#",
            "SolidColor=#SlotBackgroundColor#"
        ])
        if SETTINGS.get("skin_slide_animation_direction", 0) <= 0:
            contents.append("""MouseOverAction=[!CommandMeasure "LauhdutinScript" "OnMouseEnterSkin(false)"]""")
        contents.append("\n")

        # Slot animation meter (e.g. hover, click)
        contents.extend([
            "[SlotAnimation]",
            "Meter=Image",
            "ImageName=",
            "X=-1",
            "Y=-1",
            "W=0",
            "H=0",
            "SolidColor=0,0,0,1",
            "PreserveAspectRatio=2",
            "\n"
        ])

        # Cutout background
        contents.extend([
            "[CutoutBackground]",
            "Meter=Shape",
            "X=0",
            "Y=0",
            "Shape=Rectangle 0,0,#SkinMaxWidth#,#SkinMaxHeight# | Fill Color #SlotBackgroundColor# | StrokeWidth 0",
            "Shape2=Rectangle 0,0,0,0 | StrokeWidth 0",
            "Shape3=Combine Shape | XOR Shape2",
            "\n"
        ])

        # Slots
        nSlotNumber = 0
        for nRowColumnIndex in range(0, SLOT_ROWS_COLUMNS):
            for i in range(1, SLOT_COUNT_PER_ROW_COLUMN + 1):
                nSlotNumber += 1
                # Game title
                contents.extend([
                    "[SlotText%s]" % nSlotNumber,
                    "Meter=String",
                ])
                if i == 1: # 1st slot in a row/column
                    if nSlotNumber == 1: # 1st slot in the 1st row/column
                        contents.extend([
                            "X=%sr" % math.floor(SLOT_WIDTH / 2),
                            "Y=%sr" % math.floor(SLOT_HEIGHT / 2)
                        ])
                    else: # 1st slot in the 2nd-nth row/cooumn
                        if ORIENTATION == "vertical":
                            contents.extend([
                                "X=%sR" % math.floor(SLOT_WIDTH / 2),
                                "Y=%sR" % math.floor(0 - SLOT_COUNT_PER_ROW_COLUMN * SLOT_HEIGHT + SLOT_HEIGHT / 2)
                            ])
                        else:
                            contents.extend([
                                "X=%sR" % math.floor(0 - SLOT_COUNT_PER_ROW_COLUMN * SLOT_WIDTH + SLOT_WIDTH / 2),
                                "Y=%sR" % math.floor(SLOT_HEIGHT / 2)
                            ])
                else: # 2nd-nth slot in a row/column
                    if ORIENTATION == "vertical":
                        contents.extend([
                            "X=%sR" % math.floor(0 - SLOT_WIDTH / 2),
                            "Y=%sR" % math.floor(SLOT_HEIGHT / 2)
                        ])
                    else:
                        contents.extend([
                            "X=%sR" % math.floor(SLOT_WIDTH / 2),
                            "Y=%sR" % math.floor(0 - SLOT_HEIGHT / 2)
                        ])
                contents.extend([
                    "W=%s" % SLOT_WIDTH,
                    "H=%s" % SLOT_HEIGHT,
                    "Text=",
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
                    "[SlotBanner%s]" % nSlotNumber,
                    "Meter=Image",
                    "ImageName=",
                    "X=%sr" % math.ceil(0 - SLOT_WIDTH / 2),
                    "Y=%sr" % math.ceil(0 - SLOT_HEIGHT / 2),
                    "W=%s" % SLOT_WIDTH,
                    "H=%s" % SLOT_HEIGHT,
                    "SolidColor=0,0,0,1",
                    "PreserveAspectRatio=2",
                    "DynamicVariables=1",
                    """LeftMouseUpAction=[!CommandMeasure LauhdutinScript "OnLeftClickSlot(%s)"]""" % nSlotNumber,
                    """MiddleMouseUpAction=[!CommandMeasure LauhdutinScript "OnMiddleClickSlot(%s)"]""" % nSlotNumber,
                    """MouseOverAction=[!CommandMeasure LauhdutinScript "OnMouseEnterSlot(%s)"]""" % nSlotNumber,
                    """MouseLeaveAction=[!CommandMeasure LauhdutinScript "OnMouseLeaveSlot(%s)"]""" % nSlotNumber,
                    "Group=Slots",
                    "\n"
                ])

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
            "Text=",
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
