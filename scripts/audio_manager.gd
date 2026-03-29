extends Node
## M4: UI and combat SFX. Plays streams from res://audio/ if present; silent otherwise.

var _sfx: AudioStreamPlayer

const PATH_UI: String = "res://audio/ui_click.wav"
const PATH_HIT: String = "res://audio/hit_enemy.wav"
const PATH_DODGE: String = "res://audio/dodge.wav"
const PATH_ABILITY: String = "res://audio/ability.wav"


func _ready() -> void:
	_sfx = AudioStreamPlayer.new()
	_sfx.bus = &"Master"
	add_child(_sfx)


func play_path(path: String) -> void:
	if not ResourceLoader.exists(path):
		return
	var st: AudioStream = load(path) as AudioStream
	if st:
		_sfx.stream = st
		_sfx.play()


func play_ui() -> void:
	play_path(PATH_UI)


func play_hit() -> void:
	play_path(PATH_HIT)


func play_dodge() -> void:
	play_path(PATH_DODGE)


func play_ability() -> void:
	play_path(PATH_ABILITY)
