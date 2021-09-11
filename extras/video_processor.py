"""
A script for processing video files into entries so that Lauhdutin can be used to manage a library of videos.
Requires ffmpeg (for ffmpeg.exe and ffprobe.exe) and ImageMagick (for convert.exe).

The structure of the config file, which should be in the working directory of the script and called "video_processor_config.json":
{
	"ffmpeg": Absolute path to ffmpeg.exe.
	"ffprobe": Absolute path to ffprobe.exe.
	"convert": Absolute path to convert.exe.
	"mkv_output": Absolute path to the output folder where MKV files are placed.
	"video_inputs": A list of absolute paths to the folders where videos are stored.
	"output": The absolute path to the @Resources folder of the skin.
	"player_process": The name of your media player's process.
	"subfolders_as_categories": Whether or not the first level of subfolders should be treated as categories.
	"banner_width": The width of the banner in pixels.
	"banner_height": The height of the banner in pixels.
	"mosaic_tiles_wide": The number of frames widthwise in the mosaic thumbnail.
	"mosaic_tiles_high": The number of frames heightwise in the mosaic thumbnail.
	"tags": {
		"<tag to assign to a video>": [
			"<substring to look for in the name of a video>"
		]
	}
}
"""

import json
import math
import os
import subprocess
import sys
import ctypes
import time

CATEGORY_TITLE_SEPARATOR = " - "
TAG_SOURCES_SKIN = 1

def create_global_variables():
	res = {}
	path = os.path.join(os.getcwd(), "video_processor_config.json")
	with open(path, "r") as file:
		res = json.load(file)
	assert os.path.isfile(res.get("ffmpeg", "")), "Path to ffmpeg executable is not valid!"
	assert os.path.isfile(res.get("ffprobe", "")), "Path to ffprobe executable is not valid!"
	assert os.path.isfile(res.get("convert", "")), "Path to ImageMagick's convert executable is not valid!"
	assert os.path.isdir(res.get("mkv_output", "")), "Path to the output folder for MKVs is not valid!"
	res["video_inputs"] = res.get("video_inputs", [])
	assert len(res["video_inputs"]) > 0, "No paths to folders containing videos have been defined!"
	for library in res["video_inputs"]:
		assert os.path.isdir(library), "\"%s\" is not a valid path!" % library
	res["database_output"] = os.path.join(res.get("output", ""), "games.json")
	assert os.path.isfile(res["database_output"]), "Path to the database file is not valid!"
	res["thumbnails_output"] = os.path.join(res.get("output", ""), "cache", "custom")
	assert os.path.isdir(res["thumbnails_output"]), "Path to the thumbnails folder is not valid!"
	res["player_process"] = res.get("player_process", None)
	res["subfolders_as_categories"]  = res.get("subfolders_as_categories", False)
	assert res.get("banner_width", 0) > 0, "Banner width is invalid."
	assert res.get("banner_height", 0) > 0, "Banner height is invalid."
	assert res.get("mosaic_tiles_wide", 2) > 0, "The number of tiles widthwise in the mosaic thumbnail is invalid."
	assert res.get("mosaic_tiles_high", 2) > 0, "The number of tiles heightwise in the mosaic thumbnail is invalid."
	res["tags"] = res.get("tags", {})
	return res

def set_title(title):
	ctypes.windll.kernel32.SetConsoleTitleW(title)

# Option 1 - Drag-and-drop video files onto the script and choose this option to create copies of the videos in Matroska video containers (.mkv).
def mux_to_mkv(video):
	current_folder, name = os.path.split(video)
	name = name[:name.find(".")]
	mkv = os.path.join(CONFIG["mkv_output"], "%s.mkv" % name)
	ffmpeg = subprocess.Popen([CONFIG["ffmpeg"], "-i", video, "-f", "matroska", "-vcodec", "copy", "-acodec", "copy", mkv])
	ffmpeg.wait()

# Option 2 - Update an existing or create a new database based on the videos found in the path that you defined in your config file.
def load_database():
	db = {}
	if os.path.isfile(CONFIG["database_output"]):
		with open(CONFIG["database_output"], "r") as file:
			db = json.load(file)
	return db.get("games", []), db.get("tagsDictionary", {})

def get_duration(video):
	args = [CONFIG["ffprobe"], "-i", "%s" % video, "-show_entries", "format=duration", "-loglevel", "quiet"]
	ffprobe = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	outs, errs = ffprobe.communicate(timeout=600)
	duration_line = outs.decode("utf-8").split("\n")[1]
	return float(duration_line[9:])

def classify_duration(duration):
	interval = 10.0
	result = duration / 60.0 / interval
	lower = math.floor(result) * interval
	upper = math.ceil(result) * interval
	return "%d-%d min" % (lower, upper)

def getTagKey(allTags, tag):
	# Look for existing entry.
	for key, value in allTags.items():
		if value == tag:
			return key
	# Get next available key and add a new entry.
	i = 1
	key = "\"%s\"" % i
	while allTags.get(key) != None:
		i += 1
	allTags[key] = tag
	return key

def generate_tags(title, lookup, currentTags, allTags, newTags = []):
	sep_index = title.find(CATEGORY_TITLE_SEPARATOR)
	if sep_index >= 0:
		title = title[sep_index + len(CATEGORY_TITLE_SEPARATOR):]
	for tag, substrings in lookup.items():
		key = getTagKey(allTags, tag)
		if currentTags.get(key) != None:
			continue
		for substring in substrings:
			if substring in title:
				currentTags[key] = TAG_SOURCES_SKIN
				break
	for tag in newTags:
		key = getTagKey(allTags, tag)
		if currentTags.get(key) != None:
			continue
		currentTags[key] = TAG_SOURCES_SKIN
	return currentTags

valid_extensions = [
	".mkv",
	".mp4",
	".mov",
	".flv",
	".avi"
]

def valid_extension(file):
	for ext in valid_extensions:
		if file.endswith(ext):
			return True
	return False

def update_database(db = [], allTags = {}):
	platform_id = 5
	banner_path = "cache\\custom"
	updated_videos = 0
	# Update old entries here
	i = 0
	num_videos = len(db)
	tagLookup = CONFIG["tags"]
	for video in db:
		i += 1
		set_title("%d/%d - Updating existing entries" % (i, num_videos))
		if video["plID"] != platform_id:
			continue
		updating = False
		removing = False
		path = video["pa"][1:-1]
		if not os.path.isfile(path):
			removing = True
			os.remove(os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % video["ti"]))
			db.remove(video)
		if removing:
			print("Removing video: %s" % video.get("ti", ""))
			updated_videos += 1
		else:
			if video.get("plOv", None) == None:
				updating = True
				relpath = None
				for library in CONFIG["video_inputs"]:
					temp = os.path.relpath(video["pa"][1:-1], library)
					if relpath == None or len(temp) < len(relpath):
						relpath = temp
				assert relpath != None
				category, file = os.path.split(relpath)
				video["plOv"] = category
			old_tags = video.get("ta", {}).copy()
			new_tags = generate_tags(video["ti"], tagLookup, video.get("ta", {}), allTags)
			if len(new_tags) != len(old_tags) or len(set(new_tags) & set(old_tags)) != len(new_tags):
				updating = True
				video["ta"] = new_tags
			if updating:
				print("Updating video: %s" % video.get("ti", ""))
				updated_videos += 1
	# Add new entries
	old_videos = [video["pa"] for video in db if video.get("pa", None) != None]
	new_videos = []
	categories = []
	for library in CONFIG["video_inputs"]:
		if CONFIG["subfolders_as_categories"]:
			for root, dirs, files in os.walk(library):
				categories = dirs
				break
			for category in categories:
				for root, dirs, files in os.walk(os.path.join(library, category)):
					for file in files:
						if not valid_extension(file):
							continue
						path = "\"%s\"" % os.path.join(root, file)
						if path in old_videos:
							old_videos.remove(path)
							continue
						new_videos.append({
							"category": category,
							"root": root,
							"file": file,
							"pa": path
						})
		else:
			for root, dirs, files in os.walk(library):
				for file in files:
					if not valid_extension(file):
						continue
					path = "\"%s\"" % os.path.join(root, file)
					if path in old_videos:
						old_videos.remove(path)
						continue
					new_videos.append({
						"root": root,
						"file": file,
						"pa": path
					})
	new_entries = []
	i = 0
	num_videos = len(new_videos)
	for video in new_videos:
		i += 1
		set_title("%d/%d - Adding new entries" % (i, num_videos))
		category = video.get("category", None)
		root = video["root"]
		file = video["file"]
		path = video["pa"]
		if category != None:
			print("Adding file: %s - %s" % (category, file))
			title = "%s%s%s" % (category, CATEGORY_TITLE_SEPARATOR, file[:file.rfind(".")])
			duration = get_duration(os.path.join(root, file))
			new_entries.append({
				"pa": path,
				"prOv": CONFIG["player_process"],
				"ti": title,
				"exBa": title,
				"plID": platform_id,
				"laPl": 0,
				"hoPl": (duration / 3600.0),
				"un": False,
				"no": "%d minutes" % round(duration / 60.0),
				"ta": generate_tags(title, tagLookup, {}, allTags, [classify_duration(duration), category]),
				"plOv": category
			})
		else:
			print("Adding file: %s" % file)
			title = file[:file.rfind(".")]
			duration = get_duration(os.path.join(root, file))
			new_entries.append({
				"pa": path,
				"prOv": CONFIG["player_process"],
				"ti": title,
				"exBa": title,
				"plID": platform_id,
				"laPl": 0,
				"hoPl": (duration / 3600.0),
				"un": False,
				"no": "%d minutes" % round(duration / 60.0),
				"ta": generate_tags(title, tagLookup, {}, allTags, [classify_duration(duration)]),
			})
	db.extend(new_entries)
	return updated_videos, len(new_entries)

def save_database(db, allTags):
	with open(CONFIG["database_output"], "w") as file:
		json.dump({"version": 2, "games": db, "tagsDictionary": allTags}, file)

# Option 5 - Resize existing thumbnails.
def resize_thumbnail(path):
	width = CONFIG["banner_width"]
	height = CONFIG["banner_height"]
	resize_pattern = "%d^^x%d" % (width, height) # W^^xH or WxH^^
	convert = subprocess.Popen([CONFIG["convert"], path, "-resize", resize_pattern, "-gravity", "center", "-extent", "%dx%d" % (width, height), "-quality", "90", path])
	convert.wait()

# Option 3 - Generate thumbnails for the videos in your database.
def generate_thumbnail(args):
	video_path = args["pa"]
	timestamp = args["timestamp"]
	thumbnail = os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % args["ti"])
	ffmpeg = subprocess.Popen([CONFIG["ffmpeg"], "-i", video_path, "-ss", "00:%s.000" % timestamp, "-vframes", "1", thumbnail])
	ffmpeg.wait()
	resize_thumbnail(thumbnail)

# Option 4
def generate_mosaic_thumbnail(args):
	video_path = args["pa"]
	duration = get_duration(video_path)
	thumbnail = os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % args["ti"])
	tiles_wide = CONFIG["mosaic_tiles_wide"]
	tiles_high = CONFIG["mosaic_tiles_high"]
	num_frames = float(tiles_wide * tiles_high)
	ffmpeg = subprocess.Popen([CONFIG["ffmpeg"], "-i", video_path, "-frames", "1", "-vf", "select=if(isnan(prev_selected_t)\\,gte(t\\,10)\\,gte(t-prev_selected_t\\,%d)),tile=%dx%d" % (int(duration / num_frames), tiles_wide, tiles_high), thumbnail])
	ffmpeg.wait()
	resize_thumbnail(thumbnail)

# Program
if __name__ == "__main__":
	try:
		global CONFIG
		CONFIG = create_global_variables()
		choice = None
		options = [
			"Mux to MKV",
			"Update database",
			"Generate thumbnail",
			"Generate mosaic thumbnail",
			"Resize thumbnails",
			"Exit"
		]
		while choice != len(options):
			print("")
			i = 1
			for option in options:
				print("%d: %s" % (i, option))
				i += 1
			choice = input("\nSelect the action to perform: ")
			if choice.strip() == "":
				choice = "0"
			choice = int(choice)
			if choice == 1:
				videos = sys.argv[1:]
				if len(videos) > 0:
					videos.sort()
					i = 0
					num_videos = len(videos)
					for video in videos:
						i += 1
						set_title("%d/%d - Muxing to MKV" % (i, num_videos))
						mux_to_mkv(video)
					print("\nMuxed to MKV:")
					for video in videos:
						print("	%s" % video)
				else:
					print("\nNo videos to mux to MKV...")
			elif choice == 2:
				print("")
				db, allTags = load_database()
				updated, added = update_database(db, allTags)
				print("\nUpdated %d videos..." % updated)
				print("Added %d videos..." % added)
				print("%d videos in total..." % len(db))
				if updated > 0 or added > 0:
					save_database(db, allTags)
			elif choice == 3:
				timestamp = input("\nTimestamp (mm:ss): ")
				if timestamp.strip() == "":
					timestamp = "00:20"
				db, allTags = load_database()
				videos = []
				for video in db:
					path = os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % video["ti"])
					if os.path.isfile(path):
						continue
					videos.append({
						"pa": video["pa"][1:-1],
						"timestamp": timestamp,
						"ti": video["ti"]
					})
				if len(videos) > 0:
					videos = sorted(videos, key=lambda k: k["ti"])
					i = 0
					num_videos = len(videos)
					total_time = 0
					for video in videos:
						i += 1
						start_time = time.time()
						estimation = 0
						if i > 1:
							estimation = total_time / (i - 1) * (num_videos - i)
						set_title("%d/%d - Generating thumbnail (~%d seconds remaining)" % (i, num_videos, estimation))
						generate_thumbnail(video)
						total_time += time.time() - start_time
					print("\nGenerated thumbnail for:")
					for video in videos:
						print("	%s" % video["ti"])
				else:
					print("\nNo videos to generate thumbnails for...")
			elif choice == 4:
				db, allTags = load_database()
				videos = []
				for video in db:
					path = os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % video["ti"])
					if os.path.isfile(path):
						continue
					videos.append({
						"pa": video["pa"][1:-1],
						"ti": video["ti"]
					})
				if len(videos) > 0:
					videos = sorted(videos, key=lambda k: k["ti"])
					i = 0
					num_videos = len(videos)
					total_time = 0
					for video in videos:
						i += 1
						start_time = time.time()
						estimation = 0
						if i > 1:
							estimation = total_time / (i - 1) * (num_videos - i)
						set_title("%d/%d - Generating mosaic thumbnail (~%d seconds remaining)" % (i, num_videos, estimation))
						generate_mosaic_thumbnail(video)
						total_time += time.time() - start_time
					print("\nGenerated mosaic thumbnail for:")
					for video in videos:
						print("	%s" % video["ti"])
				else:
					print("\nNo videos to generate mosaic thumbnails for...")
			elif choice == 5:
				db, allTags = load_database()
				thumbnails = [os.path.join(CONFIG["thumbnails_output"], "%s.jpg" % video["ti"]) for video in db]
				if len(thumbnails) > 0:
					i = 0
					num_thumbnails = len(thumbnails)
					for thumbnail in thumbnails:
						i += 1
						set_title("%d/%d - Resizing thumbnail" % (i, num_thumbnails))
						resize_thumbnail(thumbnail)
					print("\nResized thumbnail:")
					for thumbnail in thumbnails:
						print("	%s" % thumbnail)
				else:
					print("\nNo thumbnails to resize...")
			else:
				pass
			set_title("Done!")
			print("\a")
	except:
		import traceback
		traceback.print_exc()
		input("\nPress enter to exit...")
