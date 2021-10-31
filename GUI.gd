extends GridContainer

signal game_paused()
signal game_start()

const GAME_STATE_OVER = "game_over"
const GAME_STATE_PAUSED = "paused"
const GAME_STATE_PLAYING = "playing"

var cur_game_state = GAME_STATE_PLAYING

var score = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_score_change(score_update):
	# print("score now ", score, ", updating by ", score_update)
	score += 1
	score += score_update
	$HUD/Score/Label.text = str(int(score))

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
	var root = get_tree()
	if Input.is_action_just_pressed("ui_select") and cur_game_state != GAME_STATE_OVER:
		emit_signal("game_paused")
		root.paused = !root.paused
		if root.paused:
			cur_game_state = GAME_STATE_PAUSED
			$MsgContainer/Message.text = "Paused"
			$MsgContainer/Message.visible = true
		else:
			cur_game_state = GAME_STATE_PLAYING
			$MsgContainer/Message.visible = false

	if Input.is_action_just_pressed("ui_accept") and cur_game_state == GAME_STATE_OVER:
		$MsgContainer/Message.visible = false
		emit_signal("game_start")
		cur_game_state = GAME_STATE_PLAYING
		score = 0
		root.paused = false

func _on_snake_game_over():
	get_tree().paused = true
	$MsgContainer/Message.text = "Game over!"
	$MsgContainer/Message.visible = true
	cur_game_state = GAME_STATE_OVER
