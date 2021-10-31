extends MarginContainer

signal game_paused()

var score = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_score_change(score_update):
	# print("score now ", score, ", updating by ", score_update)
	score += 1
	score += score_update
	$HUD/Score/Label.text = String(int(score))

func _on_snake_move_queued(move):
	var arrow
	match move.direction:
		"up":
			arrow = $HUD/Arrows/UpArrow
		"down":
			arrow = $HUD/Arrows/DownArrow
		"left":
			arrow = $HUD/Arrows/LeftArrow
		"right":
			arrow = $HUD/Arrows/RightArrow
	
	arrow.modulate = Color(1,1,1,0.2)
	yield(get_tree().create_timer(0.5), "timeout")
	arrow.modulate = Color(1,1,1,1)

func _process(_delta):
	if Input.is_action_just_pressed("ui_select"):
		var root = get_tree()
		emit_signal("game_paused")
		root.paused = !root.paused
