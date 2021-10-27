extends Node

signal grid_star_slot()
signal grid_chop_slot()

var debug_tiles = []

var collected = 0

func _ready():
	_set_item_position($Food, [], $TileGrid.map_to_world(Vector2(5,3)))
	$StarSlot.position = $TileGrid.map_to_world(Vector2(1,7))
	$ChopSlot.position = $TileGrid.map_to_world(Vector2(1,2))
	
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
	var item_tile = Vector2.ZERO
	while not new_pos:
		var new_x = randi() % 8 + 1
		var new_y = randi() % 8 + 1

		if tiles_available[new_x][new_y]:
			item_tile = Vector2(new_x, new_y)
			new_pos = $TileGrid.map_to_world(item_tile)
			break
	node.position = new_pos
	node.visible = true
	return item_tile

func spawn_next_item(tiles_available):
	collected += 1
	var food_tile = _set_item_position($Food, tiles_available)
	tiles_available[food_tile.x][food_tile.y] = true
	var star_tile = _set_item_position($Star, tiles_available)
	tiles_available[star_tile.x][star_tile.y] = true
	if collected % 3 == 0:
		var key_tile = _set_item_position($Rainbow, tiles_available)
		tiles_available[key_tile.x][key_tile.y] = true
	else:
		$Rainbow.position = Vector2(-64, -128)

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

func _on_snake_tile_change(snake):
	if snake.new_tile == Vector2(1,7):
		emit_signal("grid_star_slot")
	elif snake.new_tile == Vector2(1,2):
		emit_signal("grid_chop_slot")
