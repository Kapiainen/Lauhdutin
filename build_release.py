import sys
import os
import zipfile
import subprocess

current_working_directory = os.getcwd()

def parse_gitignore(root_path):
	print("\n  Processing .gitignore...")
	gitignore_path = os.path.join(current_working_directory, ".gitignore")
	if os.path.isfile(gitignore_path):
		gitignore = []
		with open(gitignore_path, "r") as f:
			gitignore = f.readlines()
		folders_to_ignore = []
		files_to_ignore = []
		file_patterns_to_ignore = []
		print("    Reading '%s'" % os.path.relpath(gitignore_path, current_working_directory))
		for line in gitignore:
			line = line.strip()
			path = os.path.join(current_working_directory, line)
			if os.name == "nt":
				path = path.replace("/", "\\")
			else:
				path = path.replace("\\", "/")
			if path.find(root_path):
				print("      Jumping over:", path)
				continue
			if os.path.isdir(path):
				print("      Folder:", line)
				folders_to_ignore.append(path)
			elif os.path.isfile(path):
				print("      File:", line)
				files_to_ignore.append(path)
			elif path.find("*.") >= 0:
				print("      File pattern:", line)
				file_patterns_to_ignore.append(path)
			else:
				print("      Unsupported:", line)
		print("\n    Folders to ignore")
		for line in folders_to_ignore:
			print("      '%s'" % os.path.relpath(line, current_working_directory))
		print("\n    Files to ignore")
		for line in files_to_ignore:
			print("      '%s'" % os.path.relpath(line, current_working_directory))
		return folders_to_ignore, files_to_ignore, file_patterns_to_ignore
	return None, None, None

def main(root_path, releases_path, version):
	release_name = "Lauhdutin"
	print("\nGenerating release: '%s - %s'" % (release_name, version))
	folders_to_ignore, files_to_ignore, file_patterns_to_ignore = parse_gitignore(root_path)
	print("\n  Gathering stuff to include in the release...")
	files_to_pack = []
	for root, dirs, files in os.walk(root_path):
		skip = False
		for folder in folders_to_ignore:
			if folder in root:
				skip = True
				break
		if skip:
			print("    Skipping folder:", root)
			continue
		print("    Processing folder:", root)
		for file in files:
			path = os.path.join(root, file)
			if path in files_to_ignore:
				print("      Skipping file: '%s'" % os.path.relpath(path, root_path))
			else:
				skip = False
				for pattern in file_patterns_to_ignore:
					folder_path, extension = pattern.split("*")
					if path.find(folder_path) >= 0 and path.endswith(extension):
						skip = True
						break
				if skip:
					print("      Skipping file based on pattern: '%s'" % os.path.relpath(path, root_path))
				else:
					print("      Adding file: '%s'" % os.path.relpath(path, root_path))
					if "init.lua" in path:
						with open(path, "r") as f:
							for line in f.readlines():
								if "RUN_TESTS" in line and "=" in line:
									if "true" in line:
										print("\n  Aborted build! Tests are enabled in '%s'!" % path)
										return
									else:
										break
					files_to_pack.append(path)
	print("\n  Files to pack:")
	for file in files_to_pack:
		print("     ", file)

	try: # Check if 'zlib' module is available for 'zipfile.ZipFile' to use for compressing.
		import zlib
		compression_type = zipfile.ZIP_DEFLATED
		print("\n  Using 'zlib' module to generate a compressed archive...")
	except ImportError:
		print("\n  'zlib' module could not be imported!")
		print("  Generating uncompressed archive instead...")
		compression_type = zipfile.ZIP_STORED
	readme_path = os.path.join(current_working_directory, "Readme.md")
	license_path = os.path.join(current_working_directory, "License.md")
	changelog_path = os.path.join(current_working_directory, "Changelog.md")
	contributors_path = os.path.join(current_working_directory, "Contributors.md")
	english_translation_path = os.path.join(current_working_directory, "translations", "English.txt")
	cache_folder_paths = [
		"battlenet",
		"custom",
		"gog_galaxy",
		"shortcuts",
		"steam",
		"steam_shortcuts"
	]
	with zipfile.ZipFile(os.path.join(releases_path, "%s - %s.zip" % (release_name, version)), mode="w", compression=compression_type) as release_archive:
		release_archive.write(readme_path, "Readme.md")
		release_archive.write(license_path, "License.md")
		release_archive.write(changelog_path, "Changelog.md")
		release_archive.write(contributors_path, "Contributors.md")
		release_archive.write(english_translation_path, os.path.join("@Resources", "Languages", "English.txt"))
		release_archive.writestr(zipfile.ZipInfo(os.path.join("@Resources", "Shortcuts\\")), "")
		for file in files_to_pack:
			release_archive.write(file, os.path.relpath(file, root_path))
		for folder in cache_folder_paths:
			release_archive.writestr(zipfile.ZipInfo(os.path.join("@Resources", "cache", folder + "\\")), "")
	print("\nSuccessfully generated the release!")

try:
	root_path = os.path.join(current_working_directory, "dist")
	releases_path = os.path.join(current_working_directory, "Releases")
	if not os.path.isdir(releases_path):
		os.makedirs(releases_path)
	# Compile source files
	compiler = subprocess.Popen([os.path.join(current_working_directory, "compile_src.bat")], cwd=current_working_directory)
	compiler.wait()
	if compiler.returncode == 0:
		# Update translation file
		translation_updater = subprocess.Popen(["python", os.path.join(current_working_directory, "update_translations.py")], cwd=current_working_directory)
		translation_updater.wait()
		if translation_updater.returncode == 0:
			main(root_path, releases_path, input("Enter release version: "))
		else:
			print("Failed to update the translation file!")
	else:
		print("Failed to compile source files!")
except:
	import traceback
	traceback.print_exc()
input("\nPress enter to exit...")
