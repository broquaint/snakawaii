extends KinematicBody2D

export (int) var speed = 200

var velocity = Vector2()
var last_velocity = Vector2()

var velocity_up    = Vector2(0, -200)
var velocity_down  = Vector2(0, 200)
var velocity_right = Vector2(200, 0)
var velocity_left  = Vector2(-200, 0)

func get_input():
	if Input.is_action_pressed("right"):
		return velocity_right
	if Input.is_action_pressed("left"):
		return velocity_left
	if Input.is_action_pressed("down"):
		return velocity_down
	if Input.is_action_pressed("up"):
		return velocity_up
	return null

func _process(_delta):
	var new_vel = get_input()
	if new_vel != null:
		last_velocity = new_vel

func _physics_process(_delta):
	move_and_slide(velocity)

func _on_Timer_timeout():
	velocity = last_velocity
