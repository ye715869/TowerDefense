# CardBar - 底部卡片选择栏（美化版）
extends Control

var selected_plant: int = -1
var cards: Array = []
@onready var game_manager: Node = null

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	_create_ui()

func _create_ui() -> void:
	# 底栏背景面板
	var panel = Panel.new()
	panel.size = Vector2(1000, 112)
	panel.position = Vector2(0, 548)
	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.08, 0.06, 0.04, 0.92)
	pstyle.corner_radius_top_left = 10
	pstyle.corner_radius_top_right = 10
	panel.add_theme_stylebox_override("panel", pstyle)
	add_child(panel)

	# 卡片
	var types = [GameData.PlantType.SUNFLOWER, GameData.PlantType.PEASHOOTER, GameData.PlantType.SNOW_PEA, GameData.PlantType.WALL_NUT, GameData.PlantType.CHERRY_BOMB]
	for i in range(types.size()):
		var card_scene = load("res://scenes/plant_card.tscn")
		if not card_scene: continue
		var card = card_scene.instantiate()
		card.position = Vector2(20 + i * 110, 560)
		card.setup(types[i])
		card.card_clicked.connect(_on_card_clicked)
		add_child(card)
		cards.append(card)

	# 分隔线
	var sep = HSeparator.new()
	sep.position = Vector2(15, 642)
	sep.size = Vector2(580, 2)
	add_child(sep)

	# 操作按钮区
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.15, 0.1)
	btn_style.corner_radius_top_left = 5; btn_style.corner_radius_top_right = 5
	btn_style.corner_radius_bottom_left = 5; btn_style.corner_radius_bottom_right = 5

	# 下一波按钮
	var next_btn = Button.new()
	next_btn.text = "▶ 下一波"
	next_btn.position = Vector2(600, 560)
	next_btn.size = Vector2(120, 40)
	next_btn.add_theme_stylebox_override("normal", btn_style)
	next_btn.add_theme_font_size_override("font_size", 14)
	next_btn.pressed.connect(_on_next_wave)
	add_child(next_btn)

	# 铲子按钮
	var shovel_btn = Button.new()
	shovel_btn.text = "🔧 铲除"
	shovel_btn.position = Vector2(740, 560)
	shovel_btn.size = Vector2(100, 40)
	shovel_btn.add_theme_stylebox_override("normal", btn_style)
	shovel_btn.add_theme_font_size_override("font_size", 13)
	add_child(shovel_btn)

	# 提示文字
	var tip = Label.new()
	tip.text = "💡 选择卡片 → 点击格子放置  |  右键取消"
	tip.add_theme_font_size_override("font_size", 11)
	tip.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	tip.position = Vector2(20, 650)
	tip.size = Vector2(400, 16)
	add_child(tip)

func _on_card_clicked(plant_type: int) -> void:
	if game_manager and not game_manager.can_place_plant(plant_type): return
	if selected_plant == plant_type: deselect_all(); return
	deselect_all()
	selected_plant = plant_type
	for card in cards:
		if card.has_method("set_selected"): card.set_selected(card.plant_type == plant_type)

func deselect_all() -> void:
	selected_plant = -1
	for card in cards:
		if card.has_method("set_selected"): card.set_selected(false)

func _on_next_wave() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and gm.current_state == 1: gm.next_wave()  # PLAYING
