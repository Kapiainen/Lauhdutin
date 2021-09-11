import sys
import os
import zipfile

current_working_directory = os.getcwd()

def main(root_path, releases_path, version):
	release_name = "Lauhdutin"
	print("\nGenerating translation releases...")
	try: # Check if 'zlib' module is available for 'zipfile.ZipFile' to use for compressing.
		import zlib
		compression_type = zipfile.ZIP_DEFLATED
		print("Using 'zlib' module to generate a compressed archive...")
	except ImportError:
		print("'zlib' module could not be imported!")
		print("Generating uncompressed archive instead...")
		compression_type = zipfile.ZIP_STORED
	num_translation_packages = 0
	for root, dirs, files in os.walk(root_path):
		for file in files:
			if not file.endswith(".txt") or file == "English.txt":
				continue
			language = file[:-4]
			print("Packaging: %s" % language)
			with zipfile.ZipFile(os.path.join(releases_path, "%s - %s - Translation - %s.zip"% (release_name, version, language)), mode="w", compression=compression_type) as archive:
				archive.write(os.path.join(root, file), os.path.join("@Resources", "Languages", file))
				num_translation_packages += 1
		break
	print("\nSuccessfully generated %d translation packages!" % num_translation_packages)

try:
	root_path = os.path.join(current_working_directory, "translations")
	releases_path = os.path.join(current_working_directory, "Releases")
	if not os.path.isdir(releases_path):
		os.makedirs(releases_path)
	main(root_path, releases_path, input("Enter release version: "))
except:
	import traceback
	traceback.print_exc()

input("\nPress enter to exit...")
