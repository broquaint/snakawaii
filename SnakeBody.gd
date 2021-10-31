extends KinematicBody2D

export (Vector2) var velocity = Vector2.ZERO

var prev_tile: Vector2
var turns = []
var last_turn = null

# Hacks because life is short
var tile_grid = null
var dir_offset_map = {}
var dir_map = {}

func on_tile(pos):
	var real_pos = Vector2(
		floor(pos.x + dir_offset_map[velocity].x),
		floor(pos.y + dir_offset_map[velocity].y)
	)
	return {tile=tile_grid.world_to_map(tile_grid.to_local(real_pos)),pos=real_pos}

func handle_movement():
	var next_tile = on_tile(Vector2(global_position.x+dir_map[velocity].x,global_position.y+dir_map[velocity].y))
	var cur_tile  = on_tile(global_position)
	if not turns.empty() and cur_tile.tile == turns[0].tile and next_tile.tile != cur_tile.tile:
		print(self.name, " turning at ", cur_tile, " to ", next_tile)
		var turn = turns.pop_front()
		print(self, " turn happening at ", turn, " on ", turn)
		position.x = stepify(position.x, 32)
		position.y = stepify(position.y, 32)
		velocity = turn.direction
		last_turn = turn

func _process(_delta):
	pass

func _physics_process(delta):
	handle_movement()

	move_and_collide(velocity * delta)

func _on_snake_turn(direction, turn_tile):
	turns.push_back({"direction":direction, "tile":turn_tile})
	print(self, " turning at ", turns, " now on ", on_tile(position))
