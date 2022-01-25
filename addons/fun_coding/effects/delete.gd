tool
extends Node2D

func init(key):
	if key == "Delete":
		$Particles2D.position.x = 0
		$Particles2D.scale.x = -1
	$Particles2D.emitting = true

func _on_Timer_timeout():
	queue_free()
