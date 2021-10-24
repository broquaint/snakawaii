extends KinematicBody2D

export (PackedScene) var Grid

export (Vector2) var velocity = Vector2.ZERO

var prev_tile: Vector2
var turns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func on_tile():
	var offset_pos = Vector2(position.x + 32, position.y + 32)
	return Grid.instance().get_node("TileGrid").world_to_map(offset_pos)

func _process(_delta):
	var cur_tile = on_tile()

	if prev_tile != cur_tile:
		if turns.size() > 0 and turns[0].tile == cur_tile:
			#print("turn body at ", position, " on tile ", cur_tile) 
			var turn = turns.pop_front()
			velocity = turn.direction
		#else:
			#print("body on tile ", cur_tile, " turns: ", turns)
		prev_tile = cur_tile

func _physics_process(delta):
	move_and_collide(velocity * delta)

func _on_snake_turn(direction, on_tile):
	turns.push_back({"direction":direction, "tile":on_tile})
	#print("turning at", turns[0], " now on ", on_tile())
