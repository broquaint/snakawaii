extends MarginContainer

var score = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_score_change(score_update):
	# print("score now ", score, ", updating by ", score_update)
	score += 1
	score += score_update
	$HUD/Score/Label.text = String(int(score))
