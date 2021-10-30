extends Node

signal grid_star_slot()
signal grid_chop_slot()
signal grid_exit_slot()
signal item_tile_occupied(tile)
signal item_tile_available(tile)

var debug_tiles = []

var collected = 0

func _ready():
	_set_item_position($Food, [], Vector2(5,3))
	$StarSlot.position = $TileGrid.map_to_world(Vector2(1,7))
	$ChopSlot.position = $TileGrid.map_to_world(Vector2(1,2))
	
	$StarTimer.connect("timeout", self, "_on_star_timeout")
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
	var new_pos   = $TileGrid.map_to_world(spawn_at)
	var item_tile = spawn_at
	while not new_pos:
		var new_x = randi() % 8 + 1
		var new_y = randi() % 8 + 1

		if tiles_available[new_x][new_y]:
			item_tile = Vector2(new_x, new_y)
			new_pos = $TileGrid.map_to_world(item_tile)
			break
	node.position = new_pos
	node.visible = true

	node.set_meta("current_tile", item_tile)
	
	return item_tile

func move_item(node, tiles_available):
	if node.visible:
		emit_signal("item_tile_available", node.get_meta("current_tile"))
	var tile = _set_item_position(node, tiles_available)
	emit_signal("item_tile_occupied", tile)

func _on_snake_collide(p):
	collected += 1
	match p.collided_with:
		"Food":
			move_item($Food, p.tiles_available)
		"Star":
			move_item($Star, p.tiles_available)
			$Star.modulate = Color(1,1,1,1)
			$StarTimer.start(1.5)
		"Rainbow":
			# If we reach here then this is the 3rd rainbow item
			# but it hasn't been added to the snake yet.
			if p.state.rainbow_part_count >= 2:
				$Exit.position = $TileGrid.map_to_world(Vector2(4, 1))
	if not $Star.visible and $StarTimer.time_left == 0:
		move_item($Star, p.tiles_available)
		$StarTimer.start(1.5)
	if collected % 3 == 0:
		move_item($Rainbow, p.tiles_available)
	else:
		$Rainbow.position = Vector2(-64, -128)

func _on_snake_tile_change(snake):
	if snake.new_tile == Vector2(1,7):
		emit_signal("grid_star_slot")
	elif snake.new_tile == Vector2(1,2):
		emit_signal("grid_chop_slot")
	elif snake.new_tile == Vector2(4, 1) and snake.stats.rainbow_part_count >= 3:
		emit_signal("grid_exit_slot")

func _on_star_timeout():
	var timer = $StarTimer
	# Need to stringify as match on floats doesn't seem to work ;_;
	match str(timer.wait_time):
		"1.5":
			$Star.modulate = Color(1,1,1,0.3)
			timer.start(0.4)
		"0.4":
			$Star.modulate = Color(1,1,1,1)
			timer.start(1.2)
		"1.2":
			$Star.modulate = Color(1,1,1,0.3)
			timer.start(0.3)
		"0.3":
			$Star.modulate = Color(1,1,1,1)
			timer.start(0.75)
		"0.75":
			$Star.position = Vector2(-128,-128)
			$Star.visible = false
