extends Node

func _ready():
	print("I'm ready!")
	$Snake.connect("snake_collide", $Grid, "_on_snake_collide")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var s = Snake.instance()
	#print("[", delta, "] Snake at ", s.position, " on cell ", $TileGrid.world_to_map(s.position))
