tool
extends Node2D

var fade_out = false

func _ready():
	$Particles2D.emitting = true
	$Timer.start()

func _process(delta):
	if fade_out:
		modulate.a8-=2
		if modulate.a8 <= 0:
			queue_free()

func _on_Timer_timeout():
	$Particles2D.position.x = $RichTextLabel.rect_position.x + rand_range(0, $RichTextLabel.rect_size.x)
	$Particles2D.position.y = $RichTextLabel.rect_position.y + rand_range(0, $RichTextLabel.rect_size.y)


func _on_Timer2_timeout():
	fade_out = true
