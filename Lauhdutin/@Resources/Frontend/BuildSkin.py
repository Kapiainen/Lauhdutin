# Python environment
import sys, os, subprocess, json

RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
ResourcePath = sys.argv[2][:-1]
Config = sys.argv[3][:-1]

def read_json(a_path):
	if os.path.isfile(a_path):
		with open(a_path, encoding="utf-8") as f:
			return json.load(f)
	return None

settings = read_json(os.path.join(ResourcePath, "settings.json"))

with open(os.path.join(ResourcePath, "Frontend", "GameSlots.inc"), "w") as f:
	# Variables
	f.write("""[Variables]
SlotCount=%s
SlotWidth=%s
SlotHeight=%s
SlotBackgroundColor=%s
SlotTextColor=%s
""" % (settings.get("slot_count", 6), settings.get("slot_width", 418), settings.get("slot_height", 195), settings.get("slot_background_color", "0,0,0,196"), settings.get("slot_text_color", "255,255,255,255")))
	i = 1
	while i <= int(settings.get("slot_count", 6)):
		f.write("""SlotPath%s=
SlotImage%s=
SlotName%s=
""" % (i, i, i))
		i += 1
	# Slot background
	f.write("""
[SlotBackground]
Meter=Image
X=0
Y=0
W=#SlotWidth#
H=%s
SolidColor=#SlotBackgroundColor#
""" % (int(settings.get("slot_height", 195)) * int(settings.get("slot_count", 6))))

	# Slots
	i = 1
	while i <= int(settings.get("slot_count", 6)):
		f.write("""
[SlotText%s]
Meter=String
X=(#SlotWidth#/2)
Y=(%s*#SlotHeight#+#SlotHeight#/2)
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
""" % (i, (i - 1), i))
		f.write("""
[SlotBanner%s]
Meter=Image
ImageName=#SlotImage%s#
X=0
Y=(%s*#SlotHeight#)
W=#SlotWidth#
H=#SlotHeight#
SolidColor=0,0,0,1
PreserveAspectRatio=2
DynamicVariables=1
LeftMouseUpAction=[!CommandMeasure LauhdutinScript "Launch('#SlotPath%s#')"]
Group=Slots
""" % (i, i, (i - 1), i))
		i += 1

subprocess.call([RainmeterPath, "!Refresh", Config], shell=True)