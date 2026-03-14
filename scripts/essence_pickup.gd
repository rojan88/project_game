extends Area2D
## Essence pickup: when player body enters, add to GameState and remove.

@export var essence_type: StringName = &"common"

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameState.add_essence(essence_type)
		queue_free()
