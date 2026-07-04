# PlantCard - 植物选择卡片（美化版）
class_name PlantCard
extends Control

var plant_type: int = -1
var is_selected: bool = false
var is_affordable: bool = true
var anim_time: float = 0.0

signal card_clicked(plant_type: int)

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func setup(type: int) -> void:
	plant_type = type
	var data = GameData.get_plant(type)
	if data.is_empty(): return
	var color = data.get("color", Color.WHITE)
	var cost = data.get("cost", 0)
	var name = data.get("name", "???")
	var desc = data.get("description", "")

	# 卡片背景面板
	var panel = Panel.new()
	panel.size = Vector2(98, 85)
	panel.position = Vector2(0, 0)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.2, 0.15)
	style.border_width_left = 2; style.border_width_right = 2
	style.border_width_top = 2; style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.4, 0.3)
	style.corner_radius_top_left = 6; style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6; style.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	# 植物圆形图标
	var icon = ColorRect.new()
	icon.color = color
	icon.size = Vector2(40, 40)
	icon.position = Vector2(29, 6)
	add_child(icon)

	# 名字
	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.position = Vector2(4, 48)
	name_label.size = Vector2(90, 14)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(name_label)

	# 费用
	var cost_label = Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "☀" + str(cost)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	cost_label.position = Vector2(4, 62)
	cost_label.size = Vector2(90, 18)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(cost_label)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT: card_clicked.emit(plant_type)

func set_selected(selected: bool) -> void:
	is_selected = selected
	var panel = get_child(0) if get_child_count() > 0 and get_child(0) is Panel else null
	if panel:
		var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
		if style:
			if selected:
				style.bg_color = Color(0.3, 0.25, 0.15)
				style.border_color = Color(1.0, 0.85, 0.2)
				style.border_width_left = 3; style.border_width_right = 3
				style.border_width_top = 3; style.border_width_bottom = 3
			else:
				style.bg_color = Color(0.25, 0.2, 0.15)
				style.border_color = Color(0.5, 0.4, 0.3)
				style.border_width_left = 2; style.border_width_right = 2
				style.border_width_top = 2; style.border_width_bottom = 2

func _process(_delta: float) -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and plant_type >= 0:
		var affordable = gm.can_place_plant(plant_type)
		if affordable != is_affordable:
			is_affordable = affordable
			modulate = Color.WHITE if affordable else Color(0.5, 0.5, 0.5)
			# 费用文字变红/正常
			var cl = get_node_or_null("CostLabel")
			if cl and cl is Label:
				cl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2) if affordable else Color(0.8, 0.3, 0.3))
