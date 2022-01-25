tool
extends EditorPlugin

var text_editors = []
const type_effect = preload("res://addons/fun_coding/effects/type_effect.tscn")
const lvl_up = preload("res://addons/fun_coding/effects/lvl_up.tscn")
const delete_effect = preload("res://addons/fun_coding/effects/delete.tscn")
const perfect_line = preload("res://addons/fun_coding/effects/perfect_line.tscn")
const slimey = preload("res://addons/fun_coding/effects/pet.tscn")
var slime:Control
var dock:Control
var last_key = "a"
var last_line = 0
var perfect = true

#user vars
var xp:int = 0
var lvl:int = 1
var max_xp:int = 300

var allow_delete = true 
var allow_lvl_up = true 
var allow_type = true 
var allow_perfect = true 
var allow_pet = true

#shake vars
var root = get_editor_interface().get_base_control()
var intensity:float = 0
var timer:float

#preferences
var user_config:ConfigFile = ConfigFile.new()

func _enter_tree():
	print("booting up...")
	
	#user data load
	user_config.load("user://fun_config.ini")
	xp = user_config.get_value("xp", "xp", 0)
	lvl = int(xp/300)+1
	max_xp = lvl * 300
	
	allow_delete = user_config.get_value("settings", "allow_delete", true)
	allow_lvl_up = user_config.get_value("settings", "allow_lvl_up", true)
	allow_type = user_config.get_value("settings", "allow_type", true)
	allow_perfect = user_config.get_value("settings", "allow_perfect", true)
	allow_pet = user_config.get_value("settings", "allow_pet", true)
	
	get_editor_interface().get_script_editor().connect("editor_script_changed",self,"editor_script_changed")
	
	reload()
	
	if text_editors == null:
		push_error("could not initialize plugin.")
		return
	
	dock = preload("res://addons/fun_coding/dock_panel.tscn").instance()
	dock.plugin = self
	add_control_to_bottom_panel(dock, "fun")
	dock.xp_change(xp, max_xp, lvl)
	
	if allow_pet:
		slime = slimey.instance()
		get_editor_interface().get_base_control().add_child(slime)

func reload():
	print("scrit_reloaded")
	text_editors.clear()
	find_text_edit(get_editor_interface().get_script_editor())
	for element in text_editors:
		if not element.is_connected("text_changed", self, "text_changed"):
			element.connect("text_changed", self, "text_changed", [element])
			element.connect("gui_input", self,"gui_input")

func editor_script_changed(script:Script):
	reload()

func find_text_edit(node:Node):
	for element in node.get_children():
		if element is TextEdit:
			text_editors.append(element)
		else:
			find_text_edit(element)

func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
	slime.queue_free()

func get_cursor_pos(text_editor:TextEdit)->Vector2:
	var settings = get_editor_interface().get_editor_settings()
	
	var line = text_editor.cursor_get_line()
	var column = text_editor.cursor_get_column()
	
	# Compensate for code folding
	var folding_adjustment = 0
	for i in line:
		if text_editor.is_line_hidden(i):
			folding_adjustment += 1

	# Compensate for tab size
	var tab_size = settings.get_setting("text_editor/indent/size")
	var line_text = text_editor.get_line(line).substr(0,column)
	column += line_text.count("\t") * (tab_size - 1)

	# Compensate for scroll
	var vscroll = text_editor.scroll_vertical
	var hscroll = text_editor.scroll_horizontal
	
	# Compensate for line spacing
	var line_spacing = settings.get_setting("text_editor/theme/line_spacing")
	
	# compensate fontsize
	var fontsize = text_editor.get_font("font").get_string_size(" ")
	
	# Compensate for editor scaling
	var scale = get_editor_interface().get_editor_scale()

	# Compute gutter width in characters
	var line_count = text_editor.get_line_count()
	var gutter = str(line_count).length() + 6
	
	# Compute caret position
	var pos = Vector2()
	pos.x = (gutter + column) * fontsize.x * scale - hscroll
	pos.y = (line - folding_adjustment - vscroll) * (fontsize.y + line_spacing)
	pos.y *= scale
	
	return pos

func text_changed(text_editor:TextEdit):
	type_effect(text_editor)
	
	var current_line = text_editor.cursor_get_line()
	var prev_line_text = text_editor.get_line(last_line)
	if last_key == "Enter" and current_line == last_line+1:
		if perfect and prev_line_text.dedent() != "":
			perfect_effect(text_editor)
		perfect = true
	
	last_line = text_editor.cursor_get_line()
	
	if last_key == "BackSpace" or last_key == "Delete":
		perfect = false
		delete_effect(text_editor)
	else:
		xp_increase(1)

func perfect_effect(text_editor:TextEdit):
	if not allow_perfect:
		return
	
	var effect = perfect_line.instance()
	text_editor.add_child(effect)
	
	var pos = get_cursor_pos(text_editor)
	effect.position = pos
	effect.init()

func type_effect(text_editor:TextEdit):
	if not allow_type:
		return
	
	var effect = type_effect.instance()
	text_editor.add_child(effect)
	
	var pos = get_cursor_pos(text_editor)
	effect.position = pos
	effect.init(last_key)

func xp_increase(amount:int):
	xp+=amount
	if xp>=max_xp:
		lvl+=1
		max_xp=lvl*300
		
		lvl_up_effect()
	
	dock.xp_change(xp, max_xp, lvl)

func apply_changes():
	user_config.set_value("xp", "xp", xp)
	
	user_config.set_value("settings", "allow_delete", allow_delete)
	user_config.set_value("settings", "allow_lvl_up", allow_lvl_up)
	user_config.set_value("settings", "allow_type", allow_type)
	user_config.set_value("settings", "allow_perfect", allow_perfect)
	user_config.set_value("settings", "allow_pet", allow_pet)
	
	user_config.save("user://fun_config.ini")

func lvl_up_effect():
	if not allow_lvl_up:
		return
	shake(10,0.5)
	var effect = lvl_up.instance()
	get_editor_interface().get_editor_viewport().add_child(effect)
	effect.position.x = rand_range(0, get_editor_interface().get_editor_viewport ().rect_size.x)
	effect.position.y = rand_range(0, get_editor_interface().get_editor_viewport ().rect_size.y)

func delete_effect(text_editor:TextEdit):
	if not allow_delete:
		return
	var effect = delete_effect.instance()
	text_editor.add_child(effect)
	effect.position = get_cursor_pos(text_editor)
	effect.init(last_key)

func shake(intens:float, dur:float):
	intensity = intens
	timer = dur

func _process(delta):
	if timer > 0:
		root.rect_position.x = rand_range(-intensity, intensity)
		root.rect_position.y = rand_range(-intensity, intensity)
		timer-=delta
		
		if timer <=0:
			root.rect_position = Vector2.ZERO

func gui_input(event:InputEvent):
	if event is InputEventKey and event.pressed:
		last_key = OS.get_scancode_string(event.get_scancode_with_modifiers())

func pet_toggle(create:bool):
	if create:
		slime = slimey.instance()
		get_editor_interface().get_base_control().add_child(slime)
	else:
		slime.queue_free()
