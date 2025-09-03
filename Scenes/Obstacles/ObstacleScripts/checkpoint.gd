extends Node


@export var spawn_point :Marker2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		spawn_point.global_transform = self.transform
