extends Area2D

@export var next_level = ''

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	call_deferred("load_next_scene")
	
func load_next_scene():
	get_tree().change_scene_to_file("res://scenes/forest.tscn")
