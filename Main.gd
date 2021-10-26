extends Node

func _ready():
	print("I'm ready!")
	$Snake.connect("snake_collide", $Grid, "_on_snake_collide")
	$Snake.connect("snake_tile_change", $Grid, "_on_snake_tile_change")
	$Snake.connect("debug_tile_flip", $Grid, "_on_debug_tile_flip")
	$Grid.connect("grid_star_slot", $Snake, "_on_grid_star_slot")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var s = Snake.instance()
	#print("[", delta, "] Snake at ", s.position, " on cell ", $TileGrid.world_to_map(s.position))
