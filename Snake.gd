extends KinematicBody2D

export (PackedScene) var Grid
export (PackedScene) var SnakeBody

export (int) var speed = 200

signal snake_collide(node_name, tiles_available)
signal snake_turn(direction, on_tile)
signal snake_tile_change(new_tile, old_tile)
signal debug_tile_flip(i, j, state)

var velocity_up    = Vector2(0, -150)
var velocity_down  = Vector2(0, 150)
var velocity_right = Vector2(150, 0)
var velocity_left  = Vector2(-150, 0)

var velocity = velocity_right

var body_parts = []

var prev_tile: Vector2
var moves = []

var state = {
	tiles_seen = 0,
}

onready var occupied_tiles = free_tiles()

func on_tile(pos) -> Vector2:
	# Need to offset because sprite is centered at 0,0
	return Vector2(int(floor(pos.x + 31) / 64), int(floor(pos.y + 31) / 64))

func _ready():
	position.x = 63
	position.y = 95
	prev_tile = on_tile(position)
	connect("snake_collide", self, "_on_collide_add_body_part")

func get_input():
	if Input.is_action_just_pressed("right"):
		return velocity_right
	if Input.is_action_just_pressed("left"):
		return velocity_left
	if Input.is_action_just_pressed("down"):
		return velocity_down
	if Input.is_action_just_pressed("up"):
		return velocity_up
	return null

func _process(_delta):
	var new_vel = get_input()
	if new_vel != null:
		moves.push_back(new_vel)

	var cur_tile = on_tile(position)
	if prev_tile != cur_tile:
		occupied_tiles = free_tiles()
		if moves.size() > 0:
			var turn = moves.pop_back()
			velocity = turn
			position.x = stepify(position.x, 32)
			position.y = stepify(position.y, 32)
			emit_signal("snake_turn", velocity, cur_tile)
		
		state.tiles_seen += 1
		emit_signal("snake_tile_change", {
			new_tile = cur_tile,
			stats = make_stats()
		})
		prev_tile = cur_tile
		#print("Snake at ", position, " on cell ", cur_tile, " was ", prev_tile)
		
	for i in range(0, occupied_tiles.size() - 1):
		for j in range(0, occupied_tiles[i].size() - 1):
			emit_signal("debug_tile_flip", i, j, occupied_tiles[i][j])

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		emit_signal("snake_collide", collision.collider.name, occupied_tiles)

func _on_collide_add_body_part(part_type, _tiles_available):
	var body_part
	match part_type:
		"Food":
			body_part = SnakeBody.instance().get_node("BodyPart").duplicate()
		"Star":
			body_part = SnakeBody.instance().get_node("StarPart").duplicate()
	var base = self if body_parts.empty() else body_parts.back()
	body_part.velocity = base.velocity
	body_part.position.x = base.position.x + ( 64 if base.velocity == velocity_left else -64 if base.velocity == velocity_right else 0)
	body_part.position.y = base.position.y + (-64 if base.velocity == velocity_down else 64  if base.velocity == velocity_up else 0)
	# print("Snake at ", position.x, "x", position.y, ", body part at ", body_part.position.x, "x", body_part.position.y)

	if not body_parts.empty():
		body_part.turns = base.turns.duplicate()
	body_parts.push_back(body_part)
	get_tree().get_root().add_child(body_part)
	body_part.visible = true

	connect("snake_turn", body_part, "_on_snake_turn")

func free_tiles() -> Array:
	var all_tiles = []
	for i in range(0, 10):
		all_tiles.append(range(0, 16))
		for j in range(0, 16):
			all_tiles[i][j] = true
	
	var cur_tile = on_tile(position)
	all_tiles[cur_tile.x][cur_tile.y] = false
	for bp in body_parts:
		var tile = on_tile(bp.position)
		all_tiles[tile.x][tile.y] = false
	return all_tiles

func _on_grid_star_slot():
	var new_parts = []
	for idx in range(body_parts.size()):
		var part = body_parts[idx]
		if not "StarPart".is_subsequence_of(part.name):
			new_parts.append(part.duplicate())

	for idx in range(new_parts.size()):
		var np = new_parts[idx]
		var op = body_parts[idx]
		np.velocity = op.velocity
		np.position = op.position
		np.turns    = op.turns.duplicate()
		connect("snake_turn", np, "_on_snake_turn")

	for part in body_parts:
		part.free()
	for part in new_parts:
		get_tree().get_root().add_child(part)

	body_parts = new_parts

func _on_grid_chop_slot():
	var new_parts = []
	for idx in range(body_parts.size()):
		var part = body_parts[idx]
		if idx >= floor(body_parts.size() / 2):
			new_parts.append(part.duplicate())

	for idx in range(new_parts.size()):
		var np = new_parts[idx]
		var op = body_parts[idx]
		np.velocity = op.velocity
		np.position = op.position
		np.turns    = op.turns.duplicate()
		connect("snake_turn", np, "_on_snake_turn")

	for part in body_parts:
		part.free()
	for part in new_parts:
		get_tree().get_root().add_child(part)

	body_parts = new_parts

func make_stats():
	var body_part_count = 0
	var star_part_count = 0
	for idx in range(body_parts.size()):
		var part = body_parts[idx]
		if "StarPart".is_subsequence_of(part.name):
			star_part_count += 1
		else:
			body_part_count += 1
	return {
		star_part_count = star_part_count,
		body_part_count = body_part_count,
		tiles_seen = state.tiles_seen,
	}

func _on_Timer_timeout():
	pass
