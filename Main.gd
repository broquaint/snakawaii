extends Node

signal score_update(score)

func _ready():
	print("I'm ready!")
	$Snake.connect("snake_collide", $Grid, "_on_snake_collide")
	$Snake.connect("snake_tile_change", $Grid, "_on_snake_tile_change")
	$Snake.connect("snake_tile_change", self, "_on_snake_tile_change")
	$Snake.connect("debug_tile_flip", $Grid, "_on_debug_tile_flip")
	$Grid.connect("grid_star_slot", $Snake, "_on_grid_star_slot")
	$Grid.connect("grid_chop_slot", $Snake, "_on_grid_chop_slot")
	$Grid.connect("grid_exit_slot", $Snake, "_on_grid_exit_slot")
	$Grid.connect("item_tile_available", $Snake, "_on_item_tile_available")
	$Grid.connect("item_tile_occupied",  $Snake, "_on_item_tile_occupied")
	connect("score_update", $GUI, "_on_score_change")
	$Snake.connect("snake_move_queued", $GUI, "_on_snake_move_queued")
	$GUI.connect("game_paused", $Snake, "_on_game_paused")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var s = Snake.instance()
	#print("[", delta, "] Snake at ", s.position, " on cell ", $TileGrid.world_to_map(s.position))

func _on_snake_tile_change(state):
	var stats = state.stats
	var score_delta = float(stats.tiles_seen)
	var bp_delta = score_delta * (float(stats.body_part_count) / 100)
	var sp_delta = score_delta * (float(stats.star_part_count) / 33)
	
	# print("bp delta = ", bp_delta, ", sp delta = ", sp_delta)
	emit_signal("score_update", bp_delta + sp_delta)
