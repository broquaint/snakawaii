extends KinematicBody2D

export (PackedScene) var Grid
export (PackedScene) var SnakeBody

export (int) var speed = 200

signal snake_collide(node_name)
signal snake_turn(direction, on_tile)

var velocity_up    = Vector2(0, -200)
var velocity_down  = Vector2(0, 200)
var velocity_right = Vector2(200, 0)
var velocity_left  = Vector2(-200, 0)

var velocity = velocity_right

var body_parts = []

var prev_tile: Vector2
var moves = []

func on_tile():
	# Need to offset because sprit is centered at 0,0
	var offset_pos = Vector2(position.x + 32, position.y + 32)
	return Grid.instance().get_node("TileGrid").world_to_map(offset_pos)

func _ready():
	position.x = 64
	position.y = 96
	prev_tile = on_tile()

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

	var cur_tile = on_tile()
	if prev_tile != cur_tile:
		# print("Snake at ", position, " on cell ", cur_tile, " was ", prev_tile) 
		if moves.size() > 0:
			var turn = moves.pop_back()
			velocity = turn
			emit_signal("snake_turn", velocity, cur_tile)
		prev_tile = cur_tile

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		emit_signal("snake_collide", collision.collider.name)
		match collision.collider.name:
			"Food":
				var body_part = SnakeBody.instance()
				
				var base = self if body_parts.empty() else body_parts.back()
				body_part.velocity = base.velocity
				body_part.position.x = base.position.x + ( 64 if base.velocity == velocity_left else -64 if base.velocity == velocity_right else 0)
				body_part.position.y = base.position.y + (-64 if base.velocity == velocity_down else 64  if base.velocity == velocity_up else 0)
				# print("Snake at ", position.x, "x", position.y, ", body part at ", body_part.position.x, "x", body_part.position.y)
				
				if not body_parts.empty():
					print("copying turns: ", base.turns)
					body_part.turns = base.turns.duplicate()
				body_parts.push_back(body_part)
				get_tree().get_root().add_child(body_part)
				body_part.visible = true
				
				connect("snake_turn", body_part, "_on_snake_turn")

func _on_Timer_timeout():
	pass
