extends Area2D
## Companion projectile: damage + monster-type effects via CombatEffects (M3).

var velocity: Vector2 = Vector2.ZERO
var damage: int = 1
var companion_id: StringName = &""
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
		body.take_damage(damage, EnemyBase.DMG_FLAG_RAW)
		CombatEffects.apply_companion_projectile_hit(body, damage, companion_id)
		queue_free()
