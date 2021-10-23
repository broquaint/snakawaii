extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	$Food.position = $TileGrid.map_to_world(Vector2(5,3))

func _on_snake_collide(node_name):
	print("collided with", node_name)
	if node_name == "Food":
		var new_x = randi() % 8 + 1
		var new_y = randi() % 8 + 1
		var new_pos = $TileGrid.map_to_world(Vector2(new_x, new_y))
		$Food.position = new_pos
		# emit_signal("food_collected")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
