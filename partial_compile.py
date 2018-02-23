import sys
import os
import subprocess

def main(source, target, cwd = os.getcwd()):
	num_files_to_compile = 0
	files_to_compile = {}
	for root, dirs, files in os.walk(os.path.join(cwd, source)):
		for file in files:
			if file.endswith(".moon"):
				moon_path = os.path.join(root, file)
				moon_rel_path = os.path.relpath(moon_path, source)
				lua_path = os.path.join(target, moon_rel_path).replace(".moon", ".lua")
				target_path = os.path.relpath(target, source)
				if not os.path.isfile(lua_path):
					files_to_compile[moon_rel_path] = target_path
					num_files_to_compile += 1
				else:
					moon_mod = os.path.getmtime(moon_path)
					lua_mod = os.path.getmtime(lua_path)
					if moon_mod - lua_mod > 0:
						files_to_compile[moon_rel_path] = target_path
						num_files_to_compile += 1
	if num_files_to_compile == 0:
		print("No files need to be compiled...")
		return
	for moon_path, lua_path in files_to_compile.items():
		compiler = subprocess.Popen(["moonc", "-t", lua_path, moon_path], cwd=source)
		compiler.wait()
		if compiler.returncode != 0:
			return

try:
	current_working_directory = None
	if len(sys.argv) > 1:
		current_working_directory = sys.argv[1]
	source = os.path.join(current_working_directory, "src")
	target = os.path.join(current_working_directory, "dist", "@Resources")
	main(source, target, current_working_directory)
except:
	import traceback
	traceback.print_exc()
	input("\nPress enter to exit...")
