import sys
EXPECTED_PYTHON_MAJOR_VERSION = 3
EXPECTED_PYTHON_MINOR_VERSION = 0
if (sys.version_info.major >= EXPECTED_PYTHON_MAJOR_VERSION
		and sys.version_info.minor >= EXPECTED_PYTHON_MINOR_VERSION):
	import os, zipfile

	def parse_gitignore(a_current_working_directory):
		print("  Processing .gitignore")
		gitignore_path = os.path.join(a_current_working_directory, ".gitignore")
		if os.path.isfile(gitignore_path):
			gitignore = []
			with open(gitignore_path, "r") as f:
				gitignore = f.readlines()
			folders_to_ignore = []
			files_to_ignore = []
			print("    Reading '%s'" % os.path.relpath(gitignore_path, a_current_working_directory))
			for line in gitignore:
				line = line.strip()
				path = os.path.join(a_current_working_directory, line)
				if os.name == "nt":
					path = path.replace("/", "\\")
				else:
					path = path.replace("\\", "/")
				if os.path.isdir(path):
					print("      Folder:", line)
					folders_to_ignore.append(path)
				elif os.path.isfile(path):
					print("      File:", line)
					files_to_ignore.append(path)
				else:
					print("      Unsupported:", line)
			print("    Folders to ignore")
			for line in folders_to_ignore:
				print("      '%s'" % os.path.relpath(line, a_current_working_directory))
			print("    Files to ignore")
			for line in files_to_ignore:
				print("      '%s'" % os.path.relpath(line, a_current_working_directory))
			return folders_to_ignore, files_to_ignore
		return None, None

	def get_files_to_pack(a_current_working_directory, a_source_folder):
		files_to_pack = []
		folders_to_ignore, files_to_ignore = parse_gitignore(a_current_working_directory)
		print("  Getting files to pack from: '%s' and '%s'" %
				(
					os.path.relpath(a_current_working_directory, a_current_working_directory),
					os.path.relpath(
						os.path.join(a_current_working_directory, a_source_folder),
						a_current_working_directory
					)
				)
			)
		for root, directories, files in os.walk(os.path.join(a_current_working_directory, a_source_folder)):
			if root not in folders_to_ignore:
				print("    Processing folder: '%s'" % os.path.relpath(root, a_current_working_directory))
				for file in files:
					path = os.path.join(root, file)
					if path not in files_to_ignore:
						print("      Adding file: '%s'" % os.path.relpath(path, a_current_working_directory))
						files_to_pack.append(path)
					else:
						print("      Skipping file: '%s'" % os.path.relpath(path, a_current_working_directory))
			else:
				print("    Skipping folder: '%s'" % os.path.relpath(root, a_current_working_directory))
		if files_to_pack:
			return files_to_pack
		else:
			return None

	def main(a_current_working_directory, a_release_name, a_release_version):
		print("\n\nPreparing to build release: %s - %s" % (a_release_name, a_release_version))
		skin_path = "Lauhdutin"
		files_to_pack = get_files_to_pack(a_current_working_directory, skin_path)
		if not files_to_pack:
			print("No files to add to the release archive!")
			return
		print("Files to add to archive:")
		for file in files_to_pack:
			print("  '%s'" % os.path.relpath(file, a_current_working_directory))
		releases_path = os.path.join(a_current_working_directory, "Releases")
		if not os.path.isdir(releases_path):
			os.makedirs(releases_path)
		print("Generating .zip archive")
		try: # Check if 'zlib' module is available for 'zipfile.ZipFile' to use for compressing.
			import zlib
			compression_type = zipfile.ZIP_DEFLATED
			print("  Using 'zlib' module to generate a compressed archive")
		except ImportError:
			print("  'zlib' module could not be imported")
			print("  Generating uncompressed archive")
			compression_type = zipfile.ZIP_STORED
		with zipfile.ZipFile(os.path.join(releases_path, "%s - %s.zip" % (a_release_name, a_release_version)),
								mode="w", compression=compression_type) as release_archive:
			readme_path = os.path.join(a_current_working_directory, "Readme.md")
			release_archive.write(readme_path, os.path.join(skin_path, "Readme.md"))
			license_path = os.path.join(a_current_working_directory, "License.md")
			release_archive.write(license_path, os.path.join(skin_path, "License.md"))
			for file in files_to_pack:
				release_archive.write(file, os.path.relpath(file, a_current_working_directory))
		print("Finished...")

	sys.stdout.write("Enter release version: ")
	main(os.getcwd(), "Lauhdutin", input())
else:
	print("Expected Python %s.%s, running on Python %s.%s" % (
				EXPECTED_PYTHON_MAJOR_VERSION, EXPECTED_PYTHON_MINOR_VERSION,
				sys.version_info.major, sys.version_info.minor
			)
		)
	print("Aborting...")
print("\nPress a key to exit...")
input()