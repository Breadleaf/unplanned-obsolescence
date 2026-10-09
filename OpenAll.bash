GIT_ROOT=$(git rev-parse --show-toplevel)
MACOS_PATH="/Applications/FreeCAD.app/Contents/MacOS/FreeCAD"
FREECAD_BIN=""

# if user provided args
if [ "$#" -ne 0 ]; then
	# check if user provided correct number of args
	if [ "$#" -ne 1 ]; then
		echo "Error: Incorrect usage of $0." >&2
		echo "Usage: bash $0 [optional: 'path/to/freecad']" >&2
		exit 1
	fi

	# check if $1 is a executable file
	if [ -x "$1" ]; then
		FREECAD_BIN="$1"
	else
		echo "Error: Provided path '$1' is not a valid executable." >&2
		exit 1
	fi
# Fallback to finding FreeCAD with common defaults
# else check if freecad is a valid resolution
elif command -v freecad >/dev/null 2>&1; then
	FREECAD_BIN=$(command -v freecad)
# else check if FreeCAD is a valid resolution
elif command -v FreeCAD >/dev/null 2>&1; then
	FREECAD_BIN=$(command -v FreeCAD)
# else if were on mac and freecad is installed to the normal path
elif [ "$(uname)" = "Darwin" ] && [ -x "$MACOS_PATH" ]; then
	FREECAD_BIN="$MACOS_PATH"
# else check the two normal linux paths
elif [ -x "/usr/bin/freecad" ]; then
	FREECAD_BIN="/usr/bin/freecad"
elif [ -x "/usr/local/bin/freecad" ]; then
	FREECAD_BIN="/usr/local/bin/freecad"
fi

# if the string isnt empty we have a freecad executable
if [ -z "$FREECAD_BIN" ]; then
	echo "Error: FreeCAD executable could not be found on this system." >&2
	echo "Please install FreeCAD or ensure it is added to your PATH." >&2
	exit 1
fi

echo "Found FreeCAD at: $FREECAD_BIN"

# gather all files recursively
# NOTE: `read -d ''` tells read to use NULL byte as terminator
# NOTE: `-print0` tells find outputs file paths seperated by NULL byte
# NOTE: `IFS=` clears the 'Internal Field Seperator' so trailing/leading spaces
#       aren't trimmed
FILES=()
while IFS= read -r -d '' file; do
	FILES+=("$file")
done < <(find "$GIT_ROOT/CAD/" -name "*FCStd" -print0)

# launch freecad with file paths as arguments
nohup "$FREECAD_BIN" "${FILES[@]}" >/dev/null 2>&1 &
FREECAD_PID="$!"
echo "Launched FreeCAD with PID: $FREECAD_PID."
