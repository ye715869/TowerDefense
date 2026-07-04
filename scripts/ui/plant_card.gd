# PlantCard - 单个植物选择卡片
class_name PlantCard
extends Control

var plant_type: int = -1
var is_selected: bool = false
var is_affordable: bool = true

@onready var card_bg: ColorRect = null
@onready var icon: ColorRect = null
@onready var cost_label: Label = null
@onready var name_label: Label = null

signal card_clicked(plant_type: int)

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func setup(type: int) -> void:
	plant_type = type
	var data = GameData.get_plant(type)
	if data.is_empty():
		return

	var color = data.get("color", Color.WHITE)
	var cost = data.get("cost", 0)
	var name = data.get("name", "???")

	# 卡片背景
	card_bg = ColorRect.new()
	card_bg.color = Color(0.3, 0.3, 0.3)
	card_bg.size = Vector2(95, 80)
	card_bg.position = Vector2(0, 0)
	add_child(card_bg)

	# 植物图标
	icon = ColorRect.new()
	icon.color = color
	icon.size = Vector2(50, 50)
	icon.position = Vector2(22, 5)
	add_child(icon)

	# 费用标签
	cost_label = Label.new()
	cost_label.text = "☀" + str(cost)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
	cost_label.position = Vector2(5, 58)
	cost_label.size = Vector2(85, 20)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(cost_label)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			card_clicked.emit(plant_type)

func set_selected(selected: bool) -> void:
	is_selected = selected
	if card_bg:
		card_bg.color = Color(1.0, 1.0, 1.0, 0.5) if selected else Color(0.3, 0.3, 0.3)

func _process(_delta: float) -> void:
	# 检查阳光是否足够
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and plant_type >= 0:
		var affordable = gm.can_place_plant(plant_type)
		if affordable != is_affordable:
			is_affordable = affordable
			if card_bg:
				card_bg.modulate = Color.WHITE if affordable else Color(0.4, 0.4, 0.4)
