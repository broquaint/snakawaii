extends CanvasLayer

func _ready():
	# Lines going across
	for i in range(0, 10):
		var y = i * 64
		for j in range(0, 16):
			var x = j * 64
			
			var line_vert = $GridLine.duplicate()
			line_vert.add_point(Vector2(x, 0))
			line_vert.add_point(Vector2(x, 600))
			line_vert.visible = true
			add_child(line_vert)
			
			var line_horiz = $GridLine.duplicate()
			line_horiz.add_point(Vector2(0, y))
			line_horiz.add_point(Vector2(1280, y))
			line_horiz.visible = true
			add_child(line_horiz)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
