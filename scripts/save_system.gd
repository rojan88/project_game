extends Node
## M4: Persistent save/load (user://). Call after meaningful progress.

const SAVE_PATH: String = "user://monster_pact_save.json"
const SAVE_VERSION: int = 1

signal save_completed(path: String)
signal load_completed(success: bool)


func save_game() -> bool:
	var data: Dictionary = GameState.get_save_dict()
	data["version"] = SAVE_VERSION
	var j := JSON.stringify(data)
	var err := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if err == null:
		push_error("Save failed: cannot open %s" % SAVE_PATH)
		return false
	err.store_string(j)
	err.close()
	save_completed.emit(SAVE_PATH)
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		load_completed.emit(false)
		return false
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		load_completed.emit(false)
		return false
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		load_completed.emit(false)
		return false
	GameState.apply_save_dict(parsed as Dictionary)
	load_completed.emit(true)
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
