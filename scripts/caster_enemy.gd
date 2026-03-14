extends CharacterBody2D
## Caster enemy (Combat doc): uses area spells. Red circle telegraph at player position, then damage in area.

signal died(enemy: Node2D)
signal essence_dropped(at_position: Vector2, essence_type: StringName)

@export var max_health: int = 3
@export var essence_drop_chance: float = 0.5
@export var essence_type: StringName = &"common"
@export var attack_damage: int = 2
@export var telegraph_time: float = 0.8
@export var cast_radius: float = 45.0
@export var keep_distance: float = 90.0

var current_health: int
var _state: String = "idle"
var _state_timer: float = 0.0
var _target: Node2D = null
var _cast_position: Vector2 = Vector2.ZERO
var _telegraph_indicator: Node2D = null
var _knockback_velocity: Vector2 = Vector2.ZERO

@onready var sprite: Node2D = $Sprite2D if has_node("Sprite2D") else null


func _ready() -> void:
	current_health = max_health
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	_find_player()


func _find_player() -> void:
	var tree := get_tree()
	if tree.has_group("player"):
		var players = tree.get_nodes_in_group("player")
		if players.size() > 0:
			_target = players[0] as Node2D


func _physics_process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		_find_player()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_state_timer -= delta
	velocity += _knockback_velocity
	_knockback_velocity = _knockback_velocity.move_toward(Vector2.ZERO, 600.0 * delta)

	match _state:
		"idle":
			_idle_behavior(delta)
		"telegraph":
			if _state_timer <= 0.0:
				_do_cast()
		"cooldown":
			if _state_timer <= 0.0:
				_state = "idle"
	move_and_slide()


func _idle_behavior(delta: float) -> void:
	var to_target := _target.global_position - global_position
	var dist := to_target.length()
	if dist < keep_distance - 20.0:
		# Back away
		velocity = -to_target.normalized() * 60.0
	elif dist > keep_distance + 30.0:
		velocity = to_target.normalized() * 55.0
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 200.0 * delta)
	if dist < keep_distance + 50.0 and _state_timer <= 0.0:
		_start_telegraph()


func _start_telegraph() -> void:
	_state = "telegraph"
	_state_timer = telegraph_time
	velocity = Vector2.ZERO
	_cast_position = _target.global_position
	_show_telegraph_circle()


func _show_telegraph_circle() -> void:
	var root = get_tree().current_scene
	if root == null or _telegraph_indicator != null:
		return
	_telegraph_indicator = Node2D.new()
	_telegraph_indicator.name = "CasterTelegraph"
	_telegraph_indicator.global_position = _cast_position
	var poly := Polygon2D.new()
	poly.color = Color(1, 0.15, 0.15, 0.5)
	var points: PackedVector2Array = []
	var n := 24
	for i in n:
		var a := TAU * float(i) / float(n)
		points.append(Vector2(cos(a), sin(a)) * cast_radius)
	poly.polygon = points
	_telegraph_indicator.add_child(poly)
	root.add_child(_telegraph_indicator)


func _hide_telegraph_circle() -> void:
	if _telegraph_indicator != null:
		_telegraph_indicator.queue_free()
		_telegraph_indicator = null


func _do_cast() -> void:
	_hide_telegraph_circle()
	_state = "cooldown"
	_state_timer = 1.5
	for body in get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(body):
			continue
		if _cast_position.distance_to(body.global_position) <= cast_radius and body.has_method("take_damage"):
			body.take_damage(attack_damage)


func take_damage(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		_die()


func _die() -> void:
	_hide_telegraph_circle()
	died.emit(self)
	if randf() <= essence_drop_chance:
		essence_dropped.emit(global_position, essence_type)
	queue_free()


func apply_knockback(from_position: Vector2, force: float) -> void:
	var dir := (global_position - from_position).normalized()
	_knockback_velocity = dir * force
