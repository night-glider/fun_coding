tool
extends Node2D

var modulate_spd = 0

func init(key:String):
	modulate_spd = 0.03
	$Label.text = key

func _ready():
	modulate = Color.from_hsv(randf(), 1, 1)

func _process(delta):
	if modulate_spd > 0:
		position.y-=0.3
		modulate.a-=modulate_spd
		if modulate.a <= 0:
			queue_free()
