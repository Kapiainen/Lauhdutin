import sys, os, subprocess
from tkinter import *
from tkinter import filedialog

RainmeterPath = os.path.join(sys.argv[1][:-1], "Rainmeter.exe")
#ResourcePath = sys.argv[2][:-1]
FunctionName = sys.argv[2][:-1]
InitialDir = sys.argv[3][:-1]
Config = sys.argv[4][:-1]

root = Tk()
root.withdraw()
path = filedialog.askdirectory(initialdir=InitialDir)

subprocess.call([RainmeterPath, "!CommandMeasure", "SettingsScript", "%s('%s')" % (FunctionName, path), Config], shell=True)