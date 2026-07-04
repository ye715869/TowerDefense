# CardBar - 底部卡片选择栏（新布局，与战场分离）
extends Control

var selected_plant: int = -1
var cards: Array = []
var next_wave_btn: Button = null
var shovel_btn: Button = null
var shovel_mode: bool = false
@onready var game_manager: Node = null

const PANEL_Y: float = 618.0
const CARD_Y: float = 630.0
const TIP_Y: float = 722.0

# 每张卡片的冷却覆盖层
var cooldown_overlays: Dictionary = {}
var cooldown_labels: Dictionary = {}

func _ready() -> void:
	game_manager = get_node_or_null("/root/Main/GameManager")
	if game_manager:
		game_manager.cooldown_updated.connect(_on_cooldown_updated)
	_create_ui()

func _create_ui() -> void:
	# 底栏背景面板
	var panel = Panel.new()
	panel.size = Vector2(1000, 112)
	panel.position = Vector2(0, PANEL_Y)
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
		card.position = Vector2(20 + i * 110, CARD_Y)
		card.setup(types[i])
		card.card_clicked.connect(_on_card_clicked)
		add_child(card)
		cards.append(card)

		# 冷却覆盖层
		var overlay = ColorRect.new()
		overlay.name = "CDOverlay"
		overlay.color = Color(0, 0, 0, 0.6)
		overlay.size = Vector2(98, 85)
		overlay.position = Vector2(20 + i * 110, CARD_Y)
		overlay.visible = false
		add_child(overlay)
		cooldown_overlays[types[i]] = overlay

		# 冷却倒计时文字
		var cd_label = Label.new()
		cd_label.text = ""
		cd_label.add_theme_font_size_override("font_size", 16)
		cd_label.add_theme_color_override("font_color", Color.WHITE)
		cd_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cd_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cd_label.size = Vector2(98, 85)
		cd_label.position = Vector2(20 + i * 110, CARD_Y)
		cd_label.visible = false
		add_child(cd_label)
		cooldown_labels[types[i]] = cd_label

	# 分隔线
	var sep = HSeparator.new()
	sep.position = Vector2(15, 714)
	sep.size = Vector2(580, 2)
	add_child(sep)

	# 操作按钮区
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.15, 0.1)
	btn_style.corner_radius_top_left = 5; btn_style.corner_radius_top_right = 5
	btn_style.corner_radius_bottom_left = 5; btn_style.corner_radius_bottom_right = 5

	# 下一波按钮
	next_wave_btn = Button.new()
	next_wave_btn.text = "▶ 下一波"
	next_wave_btn.position = Vector2(600, 632)
	next_wave_btn.size = Vector2(120, 40)
	next_wave_btn.add_theme_stylebox_override("normal", btn_style)
	next_wave_btn.add_theme_font_size_override("font_size", 14)
	next_wave_btn.pressed.connect(_on_next_wave)
	add_child(next_wave_btn)

	# 铲子按钮
	shovel_btn = Button.new()
	shovel_btn.text = "🔧 铲除"
	shovel_btn.position = Vector2(740, 632)
	shovel_btn.size = Vector2(100, 40)
	shovel_btn.add_theme_stylebox_override("normal", btn_style)
	shovel_btn.add_theme_font_size_override("font_size", 13)
	shovel_btn.pressed.connect(_on_shovel_pressed)
	add_child(shovel_btn)

	# 作弊按钮
	var cheat_btn = Button.new()
	cheat_btn.name = "CheatBtn"
	cheat_btn.text = "⚡ 作弊"
	cheat_btn.position = Vector2(860, 632)
	cheat_btn.size = Vector2(100, 40)
	cheat_btn.add_theme_stylebox_override("normal", btn_style)
	cheat_btn.add_theme_font_size_override("font_size", 13)
	cheat_btn.pressed.connect(_on_cheat_toggle)
	add_child(cheat_btn)

	# 提示文字
	var tip = Label.new()
	tip.text = "💡 选择卡片 → 点击格子放置  |  右键取消"
	tip.add_theme_font_size_override("font_size", 11)
	tip.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	tip.position = Vector2(20, TIP_Y)
	tip.size = Vector2(400, 16)
	add_child(tip)

func _process(_delta: float) -> void:
	# 更新波次按钮状态
	if game_manager and next_wave_btn:
		var can_skip = game_manager.can_skip_wave()
		next_wave_btn.disabled = not can_skip
		if game_manager.is_wave_in_progress():
			next_wave_btn.text = "⏳ 进行中..."
		elif not can_skip:
			next_wave_btn.text = "✓ 已完成"
		else:
			next_wave_btn.text = "▶ 下一波"

func _on_card_clicked(plant_type: int) -> void:
	if shovel_mode: _exit_shovel_mode()
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
	if game_manager and game_manager.can_skip_wave():
		game_manager.force_wave()

func _on_shovel_pressed() -> void:
	if shovel_mode:
		_exit_shovel_mode()
	else:
		# 进入铲除模式
		deselect_all()
		shovel_mode = true
		shovel_btn.text = "🔧 取消"
		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.8, 0.3, 0.1)
		s.corner_radius_top_left = 5; s.corner_radius_top_right = 5
		s.corner_radius_bottom_left = 5; s.corner_radius_bottom_right = 5
		shovel_btn.add_theme_stylebox_override("normal", s)
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)

func _exit_shovel_mode() -> void:
	shovel_mode = false
	shovel_btn.text = "🔧 铲除"
	var s = StyleBoxFlat.new()
	s.bg_color = Color(0.2, 0.15, 0.1)
	s.corner_radius_top_left = 5; s.corner_radius_top_right = 5
	s.corner_radius_bottom_left = 5; s.corner_radius_bottom_right = 5
	shovel_btn.add_theme_stylebox_override("normal", s)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_cheat_toggle() -> void:
	if not game_manager:
		return
	var active = game_manager.toggle_cheat()
	var btn = get_node_or_null("CheatBtn")
	if btn:
		if active:
			btn.text = "⚡ ON"
			var s = StyleBoxFlat.new()
			s.bg_color = Color(0.8, 0.6, 0.1)
			s.corner_radius_top_left = 5; s.corner_radius_top_right = 5
			s.corner_radius_bottom_left = 5; s.corner_radius_bottom_right = 5
			btn.add_theme_stylebox_override("normal", s)
		else:
			btn.text = "⚡ 作弊"
			var s = StyleBoxFlat.new()
			s.bg_color = Color(0.2, 0.15, 0.1)
			s.corner_radius_top_left = 5; s.corner_radius_top_right = 5
			s.corner_radius_bottom_left = 5; s.corner_radius_bottom_right = 5
			btn.add_theme_stylebox_override("normal", s)

func _on_cooldown_updated(plant_type: int, remaining: float) -> void:
	var overlay = cooldown_overlays.get(plant_type)
	if not overlay: return
	var label = cooldown_labels.get(plant_type)
	if remaining <= 0:
		overlay.visible = false
		if label: label.visible = false
	else:
		overlay.visible = true
		overlay.color = Color(0, 0, 0, 0.6)
		if label:
			label.visible = true
			label.text = str(ceil(remaining))
