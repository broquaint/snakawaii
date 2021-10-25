extends KinematicBody2D

export (PackedScene) var Grid

export (Vector2) var velocity = Vector2.ZERO

var prev_tile: Vector2
var turns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_tile(pos) -> Vector2:
	# Need to offset because sprite is centered at 0,0
	#var offset_pos = Vector2(floor(pos.x + 32), floor(pos.y + 32))
	return Vector2(int(floor(pos.x + 31) / 64), int(floor(pos.y + 31) / 64))

func _process(_delta):
	var cur_tile = on_tile(position)

	if prev_tile != cur_tile:
		if turns.size() > 0 and turns[0].tile == cur_tile:
			# print("turn body at ", position, " on tile ", cur_tile) 
			var turn = turns.pop_front()
			position.x = stepify(position.x, 32)
			position.y = stepify(position.y, 32)
			velocity = turn.direction
		# else:
		#	print("body on tile ", cur_tile, " turns: ", turns)
		prev_tile = cur_tile

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_snake_turn(direction, on_tile):
	turns.push_back({"direction":direction, "tile":on_tile})
	# print("turning at", turns[0], " now on ", on_tile(position))
