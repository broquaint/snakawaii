extends KinematicBody2D

export (Vector2) var velocity = Vector2.ZERO

var prev_tile: Vector2
var turns = []

# Hacks because life is short
var tile_grid = null
var dir_offset_map = {}
var dir_map = {}

func on_tile(pos) -> Vector2:
	var real_pos = Vector2(
		pos.x + dir_offset_map[velocity].x,
		pos.y + dir_offset_map[velocity].y
	)
	return tile_grid.world_to_map(tile_grid.to_local(real_pos))

func handle_movement():
	var next_tile = on_tile(Vector2(global_position.x+dir_map[velocity].x,global_position.y+dir_map[velocity].y))
	var cur_tile = on_tile(global_position)
	if not turns.empty() and cur_tile == turns[0].tile and next_tile != cur_tile:
		var turn = turns.pop_front()
		print(self, "turn happening at ", turn, " on ", turn)
		position.x = stepify(position.x, 32)
		position.y = stepify(position.y, 32)
		velocity = turn.direction
		# Don't know why SnakeBody doesn't see the Grid PackScene; past caring
		#emit_signal("snake_turn", velocity, cur_tile, Grid.instance().get_node("TileGrid"), dir_offset_map)

func _process(_delta):
	if tile_grid == null:
		return
		
	handle_movement()
	#var cur_tile = on_tile(global_position)

	#if turns.size() > 0 and turns[0].tile == cur_tile:
	#	# print("turn body at ", position, " on tile ", cur_tile) 
	#	var turn = turns.pop_front()
	#	position.x = stepify(position.x, 32)
	#	position.y = stepify(position.y, 32)
	#	velocity = turn.direction
	#	# else:
	#	#	print("body on tile ", cur_tile, " turns: ", turns)
	#	prev_tile = cur_tile

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_snake_turn(direction, turn_tile, tg, domap, dmap):
	tile_grid = tg
	dir_offset_map = domap
	dir_map = dmap
	turns.push_back({"direction":direction, "tile":turn_tile})
	print(self, "turning at", turns, " now on ", on_tile(position))
