extends Area2D

@export var areaType: String


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		body.mode = areaType
