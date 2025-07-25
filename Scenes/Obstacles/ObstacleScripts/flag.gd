extends Area2D

@export var nextLevelName: String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.celebrate()
		body.nextLevelName = nextLevelName
