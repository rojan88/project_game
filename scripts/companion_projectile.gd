extends Area2D
## Projectile spawned by companion: moves in direction, damages first enemy hit, grants companion exp.

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var companion_id: StringName = &""
var status_effect: StringName = &""   # e.g. &"poison" for Plant Sprite
var status_duration: float = 0.0
var _hit: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(3.0).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if _hit:
		return
	if body.is_in_group("enemy") and body.has_method("take_damage"):
		_hit = true
		body.take_damage(damage)
		if status_effect != &"" and status_duration > 0.0 and body.has_method("add_status"):
			body.add_status(status_effect, status_duration)
		queue_free()
