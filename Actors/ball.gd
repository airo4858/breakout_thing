extends CharacterBody2D

@export var speed: float = 3.0
@export var max_speed: float = 10.0
@export var score_label: RichTextLabel
@export var StartText: RichTextLabel
var forward = Vector2(1,1).normalized()
const paddle_width: float = 100.0
var current_score: int = 0
var is_running: bool = false
var multi_ball: int = 1

#func _ready() -> void:
	#velocity = Vector2(1,1).normalized()
func dupli(position: Vector2) -> void:
	var newBall: Node = duplicate()
	multi_ball = multi_ball + 1
	if newBall:
		newBall.position = position + Vector2(40,0)
		newBall.visible = true;
		newBall.is_running = true;
		newBall.speed = 5
		if get_parent():
			get_parent().add_child(newBall)

func _physics_process(delta: float) -> void:
	if (not is_running):
		if (Input.is_action_just_pressed("StartScreen")):
			is_running = true
			StartText.visible = false
			visible = true
			
		return
	
	var collision: KinematicCollision2D = move_and_collide(forward * speed)
	if (collision):
		forward = forward.bounce(collision.get_normal())
		speed = clamp(speed + 0.2, 2, 10)
		
		if (collision.get_collider().is_in_group("Bricks")):
			collision.get_collider().queue_free()
			current_score += 10
			score_label.text = "Score: " + str(current_score)
			
		if (collision.get_collider().is_in_group("Paddle")):
			var paddle_x = collision.get_collider().position.x - paddle_width /2
			var pos_on_paddle = (position.x - paddle_x) / paddle_width
			print("Hit the Paddle!")
			var bounce_angle = lerp(-PI * 0.8, -PI * 0.2, pos_on_paddle)
			forward = Vector2.from_angle(bounce_angle)
			
		if (collision.get_collider().is_in_group("GameOver")):
			if (multi_ball == 1):
				StartText.visible = true
				StartText.text = "GAME OVER"
				is_running = false
			multi_ball = multi_ball - 1
			
		if (collision.get_collider().is_in_group("SlowDown")):
			speed = speed / 2
			current_score += 10
		
		if (collision.get_collider().is_in_group("Double")):
			speed = speed * 2
			
		if (collision.get_collider().is_in_group("Duplicate")):
			dupli(position)
