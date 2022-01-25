tool
extends Control

var active = false
var target:Vector2 = Vector2.ZERO

var default_speed = 1
var panic_speed = 5

var instruction = 0
#0 - stand still
#1 - heading to point
#2 - panic

func instruction_0_init():
	instruction = 0

func instruction_1_init():
	instruction = 1
	target.x = rand_range(0,get_viewport_rect().size.x)
	target.y = rand_range(0,get_viewport_rect().size.y)

func instruction_2_init():
	instruction = 2

func _ready():
	instruction_0_init()

func _process(delta):
	$AnimatedSprite.flip_h = target.x - rect_position.x > 0
	
	if instruction == 0:
		if randf() < 0.01:
			instruction_1_init()
	
	if instruction == 1:
		rect_position = rect_position.move_toward(target, default_speed)
		if rect_position == target:
			instruction_0_init()
	
	if instruction == 2:
		if randf() < 0.1:
			target.x = rand_range(0,get_viewport_rect().size.x)
			target.y = rand_range(0,get_viewport_rect().size.y)
		rect_position = rect_position.move_toward(target, panic_speed)
	
	if active and Input.is_mouse_button_pressed(BUTTON_LEFT):
		rect_position = get_global_mouse_position() - (rect_size/2)*rect_scale


func _on_Control_mouse_entered():
	active = true

func _on_Control_mouse_exited():
	active = false
