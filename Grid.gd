extends Node

signal grid_star_slot()

var debug_tiles = []

func _ready():
	_set_item_position($Food, [], $TileGrid.map_to_world(Vector2(5,3)))
	$StarSlot.position = $TileGrid.map_to_world(Vector2(1,7))
	
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

func _set_item_position(node, tiles_available, spawn_at = Vector2.ZERO):
	var new_pos = spawn_at
	while not new_pos:
		var new_x = randi() % 8 + 1
		var new_y = randi() % 8 + 1

		if tiles_available[new_x][new_y]:
			new_pos = $TileGrid.map_to_world(Vector2(new_x, new_y))
			break
	node.position = new_pos
	node.visible = true
	print("Setting ", node, " at ", new_pos)

func spawn_next_item(tiles_available):
	_set_item_position($Food if randi() % 2 == 0 else $Star, tiles_available)

func _on_snake_collide(node_name, tiles_available):
	print("collided with: ", node_name)
	match node_name:
		"Food":
			$Food.visible = false
			$Food.position = Vector2(-128,-128)
			# emit_signal("food_collected")
		"Star":
			$Star.visible = false
			$Star.position = Vector2(-128,-128)
			# emit_signal("star_collected")
	spawn_next_item(tiles_available)

func _on_snake_tile_change(new_tile, _old_tile):
	if new_tile == Vector2(1,7):
		emit_signal("grid_star_slot")
