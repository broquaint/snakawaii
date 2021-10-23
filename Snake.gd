extends KinematicBody2D

export (PackedScene) var Grid

export (int) var speed = 200

signal snake_collide(node_name)

var velocity_up    = Vector2(0, -200)
var velocity_down  = Vector2(0, 200)
var velocity_right = Vector2(200, 0)
var velocity_left  = Vector2(-200, 0)

var velocity = velocity_right

var prev_tile: Vector2
var moves = []

func on_tile():
	return Grid.instance().get_node("TileGrid").world_to_map(position)

func _ready():
	position.x = 64
	position.y = 64
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
		print("Snake at ", position, " on cell ", cur_tile, " was ", prev_tile) 
		if moves.size() > 0:
			velocity = moves.pop_back()
		prev_tile = cur_tile

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		emit_signal("snake_collide", collision.collider.name)

func _on_Timer_timeout():
	pass
