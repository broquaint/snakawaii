extends Node

var debug_tiles = []

func _ready():
	$Food.position = $TileGrid.map_to_world(Vector2(5,3))
	
	for i in range(0, 10):
		debug_tiles.append(range(0, 16))
		for j in range(0, 16):
			var tile = $DebugTile.duplicate()
			var txt  = $DebugTile/DebugPos.duplicate()
			var pos  = Vector2(i, j)
			tile.set_global_position($TileGrid.map_to_world(pos))
			txt.set_global_position($TileGrid.map_to_world(pos))
			txt.text = " %dx%d" % [i,j]
			add_child(tile)
			add_child(txt)
			debug_tiles[i][j] = tile

func _on_debug_tile_flip(i, j, state):
	debug_tiles[i][j].visible = state

func _on_snake_collide(node_name, tiles_available):
	# print("collided with: ", node_name)
	if node_name == "Food":
		#print("tiles available: ", tiles_available)
		var new_pos = Vector2()
		while not new_pos:
			var new_x = randi() % 8 + 1
			var new_y = randi() % 8 + 1
			
			if tiles_available[new_x][new_y]:
				new_pos = $TileGrid.map_to_world(Vector2(new_x, new_y))
				break
		$Food.position = new_pos
		# emit_signal("food_collected")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
