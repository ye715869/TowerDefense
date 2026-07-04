# PlantCard - 植物选择卡片（Button 重制版）
class_name PlantCard
extends Control

var plant_type: int = -1
var is_selected: bool = false
var is_affordable: bool = true

signal card_clicked(plant_type: int)

func setup(type: int) -> void:
	plant_type = type
	var data = GameData.get_plant(type)
	if data.is_empty(): return
	var color = data.get("color", Color.WHITE)
	var cost = data.get("cost", 0)
	var name = data.get("name", "???")

	# 使用 Button 确保点击可靠
	var btn = Button.new()
	btn.name = "CardBtn"
	btn.flat = true
	btn.size = Vector2(98, 85)
	btn.position = Vector2(0, 0)
	btn.pressed.connect(_on_pressed)
	add_child(btn)

	# 自定义按钮样式
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.25, 0.2, 0.15)
	normal_style.border_width_left = 2; normal_style.border_width_right = 2
	normal_style.border_width_top = 2; normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.5, 0.4, 0.3)
	normal_style.corner_radius_top_left = 6; normal_style.corner_radius_top_right = 6
	normal_style.corner_radius_bottom_left = 6; normal_style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", normal_style)

	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(0.3, 0.25, 0.18)
	hover_style.border_width_left = 2; hover_style.border_width_right = 2
	hover_style.border_width_top = 2; hover_style.border_width_bottom = 2
	hover_style.border_color = Color(0.7, 0.55, 0.4)
	hover_style.corner_radius_top_left = 6; hover_style.corner_radius_top_right = 6
	hover_style.corner_radius_bottom_left = 6; hover_style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("hover", hover_style)

	# 植物圆形图标
	var icon = ColorRect.new()
	icon.name = "Icon"
	icon.color = color
	icon.size = Vector2(40, 40)
	icon.position = Vector2(29, 6)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(icon)

	# 名字
	var name_label = Label.new()
	name_label.text = name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.position = Vector2(4, 48)
	name_label.size = Vector2(90, 14)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(name_label)

	# 费用
	var cost_label = Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = "☀" + str(cost)
	cost_label.add_theme_font_size_override("font_size", 13)
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	cost_label.position = Vector2(4, 62)
	cost_label.size = Vector2(90, 18)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(cost_label)

func _on_pressed() -> void:
	card_clicked.emit(plant_type)

func set_selected(selected: bool) -> void:
	is_selected = selected
	var btn = get_node_or_null("CardBtn")
	if not btn: return
	if selected:
		var sel_style = StyleBoxFlat.new()
		sel_style.bg_color = Color(0.3, 0.25, 0.15)
		sel_style.border_width_left = 3; sel_style.border_width_right = 3
		sel_style.border_width_top = 3; sel_style.border_width_bottom = 3
		sel_style.border_color = Color(1.0, 0.85, 0.2)
		sel_style.corner_radius_top_left = 6; sel_style.corner_radius_top_right = 6
		sel_style.corner_radius_bottom_left = 6; sel_style.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", sel_style)
	else:
		var normal_style = StyleBoxFlat.new()
		normal_style.bg_color = Color(0.25, 0.2, 0.15)
		normal_style.border_width_left = 2; normal_style.border_width_right = 2
		normal_style.border_width_top = 2; normal_style.border_width_bottom = 2
		normal_style.border_color = Color(0.5, 0.4, 0.3)
		normal_style.corner_radius_top_left = 6; normal_style.corner_radius_top_right = 6
		normal_style.corner_radius_bottom_left = 6; normal_style.corner_radius_bottom_right = 6
		btn.add_theme_stylebox_override("normal", normal_style)

func _process(_delta: float) -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and plant_type >= 0:
		var affordable = gm.can_place_plant(plant_type)
		if affordable != is_affordable:
			is_affordable = affordable
			modulate = Color.WHITE if affordable else Color(0.5, 0.5, 0.5)
			var cl = get_node_or_null("CardBtn/CostLabel")
			if cl and cl is Label:
				var col = Color(1.0, 0.85, 0.2) if affordable else Color(0.8, 0.3, 0.3)
				cl.add_theme_color_override("font_color", col)
