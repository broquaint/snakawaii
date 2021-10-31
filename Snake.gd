extends KinematicBody2D

export (PackedScene) var Grid
export (PackedScene) var SnakeBody

export (int) var speed = 150

signal snake_collide(node_name, tiles_available)
signal snake_turn(direction, on_tile)
signal snake_tile_change(new_tile, old_tile)
signal debug_tile_flip(i, j, state)
signal snake_move_queued(move)
signal snake_game_over()

var velocity_up    = Vector2(0, -speed)
var velocity_down  = Vector2(0, speed)
var velocity_right = Vector2(speed, 0)
var velocity_left  = Vector2(-speed, 0)

var velocity = velocity_right

var body_parts = []

var prev_tile: Vector2
var moves = []

var state

var occupied_item_tiles: Array
var occupied_tiles: Array

var dir_offset_map = {}
var dir_map = {}
func _ready():
	dir_offset_map[velocity_up] = Vector2(0,-32)
	dir_offset_map[velocity_down] = Vector2(0, 32)
	dir_offset_map[velocity_right] = Vector2(32, 0)
	dir_offset_map[velocity_left] = Vector2(-32, 0)
	
	dir_map[velocity_up] = Vector2(0,-4)
	dir_map[velocity_down] = Vector2(0, 4)
	dir_map[velocity_right] = Vector2(4, 0)
	dir_map[velocity_left] = Vector2(-4, 0)
	
	connect("snake_collide", self, "_on_collide_add_body_part")
	
	start_game()
	
func start_game():
	position.x = 64
	position.y = 96
	velocity = velocity_right
	prev_tile = on_tile(position)
	moves = []
	
	state = {
		tiles_seen = 0,
		tiles_entered = []
	}
	
	# Track item tiles separately as they change out of band.
	occupied_item_tiles = []
	for i in range(0, 10):
		occupied_item_tiles.append(range(0, 16))
		for j in range(0, 16):
			occupied_item_tiles[i][j] = true
	occupied_tiles = free_tiles()

	for part in body_parts:
		part.free()

	body_parts = []
	
func _on_game_start():
	start_game()

func _on_game_paused():
	var grid = Grid.instance().get_node("TileGrid")
	for part in body_parts:
		var tile =  grid.world_to_map(grid.to_local(part.position))
		print(part.name, " at ", tile, "[", part.position, "] velocity ", part.velocity, " turns ", part.turns)


func get_input():
	if Input.is_action_just_pressed("right") and velocity != velocity_left:
		return {velocity=velocity_right,direction="right"}
	if Input.is_action_just_pressed("left") and velocity != velocity_right:
		return {velocity=velocity_left,direction="left"}
	if Input.is_action_just_pressed("down") and velocity != velocity_up:
		return {velocity=velocity_down,direction="down"}
	if Input.is_action_just_pressed("up") and velocity != velocity_down:
		return {velocity=velocity_up,direction="up"}
	return null

func handle_movement():
	var new_vel = get_input()
	if new_vel != null:
		moves=[new_vel.velocity]
		emit_signal("snake_move_queued", new_vel)

	var next_tile = on_tile(Vector2(global_position.x+dir_map[velocity].x,global_position.y+dir_map[velocity].y))
	var cur_tile = on_tile(global_position)
	if not moves.empty() and moves.back() != velocity and next_tile != cur_tile:
		var turn = moves.pop_back()
		# Move to _physicss_process
		position.x = stepify(position.x, 32)
		position.y = stepify(position.y, 32)
		velocity = turn
		# Don't know why SnakeBody doesn't see the Grid PackScene; past caring
		emit_signal("snake_turn", velocity, cur_tile)

func track_tiles(cur_tile):
	occupied_tiles = free_tiles()

	state.tiles_seen += 1
	emit_signal("snake_tile_change", {
		new_tile = cur_tile,
		stats = make_stats()
	})
	prev_tile = cur_tile
	state.tiles_entered.push_front(cur_tile)

func _process(_delta):
	var cur_tile = on_tile(global_position)
	if prev_tile != cur_tile:
		track_tiles(cur_tile)

	for i in range(0, occupied_tiles.size() - 1):
		for j in range(0, occupied_tiles[i].size() - 1):
			emit_signal("debug_tile_flip", i, j, occupied_tiles[i][j])

func _physics_process(delta):
	handle_movement()
	var collision = move_and_collide(velocity * (delta + 0.1), true, true, true)
	if collision:
		emit_signal("snake_collide", {
			collided_with = collision.collider.name,
			tiles_available = occupied_tiles,
			state = make_stats()
		})
	move_and_collide(velocity * delta)

func _on_collide_add_body_part(p):
	if "Part".is_subsequence_of(p.collided_with) or "Wall".is_subsequence_of(p.collided_with):
		emit_signal("snake_game_over")
		return

	var body_part = build_body_part_for(p.collided_with)

	var base = self if body_parts.empty() else body_parts.back()
	body_part_based_on(body_part, base)
	body_part.position.x = base.position.x + ( 64 if base.velocity == velocity_left else -64 if base.velocity == velocity_right else 0)
	body_part.position.y = base.position.y + (-64 if base.velocity == velocity_down else 64  if base.velocity == velocity_up else 0)

	body_parts.push_back(body_part)
	get_tree().get_root().add_child(body_part)
	body_part.visible = true

func build_body_part_for(part_type):
	match part_type:
		"Food":
			return SnakeBody.instance().get_node("BodyPart").duplicate()
		"Star":
			return SnakeBody.instance().get_node("StarPart").duplicate()
		"Rainbow":
			return SnakeBody.instance().get_node("RainbowPart").duplicate()
	print("Didn't know what to do with ", part_type)

func build_body_part_from(part):
	if is_part(part, "Body"):
		return build_body_part_for("Food")
	elif is_part(part, "Star"):
		return build_body_part_for("Star")
	elif is_part(part, "Rainbow"):
		return build_body_part_for("Rainbow")

	print("Didn't know what to do with ", part)

func body_part_based_on(body_part, base):
	body_part.velocity = base.velocity
	body_part.position = base.position
	if not body_parts.empty():
		body_part.turns = base.turns.duplicate(true)

	body_part.tile_grid = Grid.instance().get_node("TileGrid")
	body_part.dir_offset_map = dir_offset_map
	body_part.dir_map = dir_map

	body_part.visible = true

	connect("snake_turn", body_part, "_on_snake_turn")

func _on_grid_star_slot():
	var new_parts = []
	for part in body_parts:
		if not is_part(part, "Star"):
			new_parts.append(build_body_part_from(part))

	for idx in range(new_parts.size()):
		var np = new_parts[idx]
		var op = body_parts[idx]
		body_part_based_on(np, op)

	for part in body_parts:
		part.free()
	for part in new_parts:
		get_tree().get_root().add_child(part)

	body_parts = new_parts
	# Handle when the head has turned on this tile.
	if not body_parts.empty() and not moves.empty():
		var fbp = body_parts[0]
		fbp.velocity = velocity
		if not fbp.turns.empty():
			fbp.turns.pop_front()

func _on_grid_chop_slot():
	var choppable_count = 0
	for part in body_parts:
		if not is_part(part, "Rainbow"):
			choppable_count += 1
	var new_parts = []
	var parts_seen = 0
	for part in body_parts:
		if is_part(part, "Rainbow"):
			new_parts.append(build_body_part_from(part))
		else:
			# Drop about half the parts.
			if not(parts_seen >= float(floor(choppable_count / 2))): 
				new_parts.append(build_body_part_from(part))
			parts_seen += 1

	for idx in range(new_parts.size()):
		var np = new_parts[idx]
		var op = body_parts[idx]
		body_part_based_on(np, op)

	for part in body_parts:
		part.free()
	for part in new_parts:
		get_tree().get_root().add_child(part)

	body_parts = new_parts
	# Handle when the head has turned on this tile.
	if not body_parts.empty() and not moves.empty():
		var fbp = body_parts[0]
		fbp.velocity = velocity
		if not fbp.turns.empty():
			fbp.turns.pop_front()

func _on_grid_exit_slot():
	print("Exit level code goes here \\o/")

func _on_item_tile_available(tile):
	occupied_tiles[tile.x][tile.y] = true
	occupied_item_tiles[tile.x][tile.y] = true

func _on_item_tile_occupied(tile):
	occupied_tiles[tile.x][tile.y] = false
	occupied_item_tiles[tile.x][tile.y] = false

func make_stats():
	var body_part_count = 0
	var star_part_count = 0
	var rainbow_part_count = 0
	for idx in range(body_parts.size()):
		var part = body_parts[idx]
		if is_part(part, "Star"):
			star_part_count += 1
		elif is_part(part, "Body"):
			body_part_count += 1
		elif is_part(part, "Rainbow"):
			rainbow_part_count += 1

	return {
		star_part_count = star_part_count,
		body_part_count = body_part_count,
		rainbow_part_count = rainbow_part_count,
		tiles_seen = state.tiles_seen,
	}

func free_tiles() -> Array:
	var all_tiles = []
	for i in range(0, 10):
		all_tiles.append(range(0, 16))
		for j in range(0, 16):
			all_tiles[i][j] = true

	for i in range(0, occupied_item_tiles.size()):
		for j in range(0, occupied_item_tiles[i].size()):
			all_tiles[i][j] = occupied_item_tiles[i][j]

	var cur_tile = on_tile(position)
	all_tiles[cur_tile.x][cur_tile.y] = false 

	var te_end = body_parts.size() + 1 if body_parts.size() + 1 < state.tiles_entered.size() else body_parts.size()
	var on_tiles = state.tiles_entered.slice(0, te_end)
	for tile in on_tiles:
		if tile != null:
			all_tiles[tile.x][tile.y] = false

	# Possible early optimization
	state.tiles_entered.resize(body_parts.size()*2)

	return all_tiles

func on_tile(pos) -> Vector2:
	var grid = Grid.instance().get_node("TileGrid")
	var real_pos = Vector2(
		floor(pos.x + dir_offset_map[velocity].x),
		floor(pos.y + dir_offset_map[velocity].y)
	)
	$TilePos.global_position = grid.to_local(	real_pos)
	return grid.world_to_map(grid.to_local(real_pos))

func is_part(part, part_name):
	return part_name.is_subsequence_of(part.name)
