tool
extends Control

var plugin:EditorPlugin = null

func _ready():
	$GridContainer/delete.pressed = plugin.allow_delete
	$GridContainer/lvl_up.pressed = plugin.allow_lvl_up
	$GridContainer/type.pressed = plugin.allow_type
	$GridContainer/perfect_line.pressed = plugin.allow_perfect
	$GridContainer/pet.pressed = plugin.allow_pet

func xp_change(new_xp:int, new_max_xp:int, level:int):
	$VBoxContainer/XP_container/XP_count.text = str(new_xp) + "/" + str(new_max_xp)
	$VBoxContainer/XP_container/level.text = "LEVEL " + str(level)
	$VBoxContainer/TextureProgress.max_value = new_max_xp
	$VBoxContainer/TextureProgress.min_value = new_max_xp - 300
	$VBoxContainer/TextureProgress.value = new_xp

func update_settings():
	plugin.allow_delete = $GridContainer/delete.pressed
	plugin.allow_lvl_up = $GridContainer/lvl_up.pressed
	plugin.allow_type = $GridContainer/type.pressed
	plugin.allow_perfect = $GridContainer/perfect_line.pressed


func _on_pet_pressed():
	plugin.allow_pet = $GridContainer/pet.pressed
	plugin.pet_toggle($GridContainer/pet.pressed)
