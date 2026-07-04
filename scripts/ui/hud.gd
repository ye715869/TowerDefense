# HUD - 顶部信息栏（美化版）
extends CanvasLayer

@onready var sun_label: Label = null
@onready var wave_label: Label = null
@onready var base_health_bar: ProgressBar = null
@onready var state_label: Label = null
@onready var start_button: Button = null

func _ready() -> void:
	_create_ui()
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.sun_changed.connect(_on_sun_changed)
		gm.wave_changed.connect(_on_wave_changed)
		gm.base_health_changed.connect(_on_base_health_changed)
		gm.state_changed.connect(_on_state_changed)
		sun_label.text = "☀ " + str(gm.sun)

func _create_ui() -> void:
	# 顶部深色面板
	var panel = Panel.new()
	panel.size = Vector2(1000, 72)
	panel.position = Vector2(0, 0)
	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.08, 0.06, 0.04, 0.92)
	pstyle.corner_radius_bottom_left = 8
	pstyle.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", pstyle)
	add_child(panel)

	# 阳光区域
	var sun_bg = Panel.new()
	sun_bg.position = Vector2(12, 10)
	sun_bg.size = Vector2(180, 52)
	var sstyle = StyleBoxFlat.new()
	sstyle.bg_color = Color(0.15, 0.12, 0.08, 0.8)
	sstyle.corner_radius_top_left = 10; sstyle.corner_radius_top_right = 10
	sstyle.corner_radius_bottom_left = 10; sstyle.corner_radius_bottom_right = 10
	sstyle.border_width_left = 2; sstyle.border_width_right = 2
	sstyle.border_width_top = 2; sstyle.border_width_bottom = 2
	sstyle.border_color = Color(0.6, 0.5, 0.2)
	sun_bg.add_theme_stylebox_override("panel", sstyle)
	panel.add_child(sun_bg)

	# 太阳图标
	var sun_icon = ColorRect.new()
	sun_icon.color = Color(1.0, 0.85, 0.1)
	sun_icon.size = Vector2(32, 32)
	sun_icon.position = Vector2(26, 20)
	panel.add_child(sun_icon)

	sun_label = Label.new()
	sun_label.text = "150"
	sun_label.add_theme_font_size_override("font_size", 26)
	sun_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	sun_label.add_theme_font_override("font", load("res://assets/fonts/default_font.tres") if ResourceLoader.exists("res://assets/fonts/default_font.tres") else ThemeDB.fallback_font)
	sun_label.position = Vector2(66, 18)
	sun_label.size = Vector2(120, 36)
	panel.add_child(sun_label)

	# 波次信息
	wave_label = Label.new()
	wave_label.text = "波次 0/0"
	wave_label.add_theme_font_size_override("font_size", 18)
	wave_label.add_theme_color_override("font_color", Color.WHITE)
	wave_label.position = Vector2(400, 20)
	wave_label.size = Vector2(180, 30)
	panel.add_child(wave_label)

	# 基地血量标签
	var base_lbl = Label.new()
	base_lbl.text = "🏠 基地"
	base_lbl.add_theme_font_size_override("font_size", 13)
	base_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	base_lbl.position = Vector2(600, 10)
	base_lbl.size = Vector2(100, 16)
	panel.add_child(base_lbl)

	base_health_bar = ProgressBar.new()
	base_health_bar.value = 100.0
	base_health_bar.size = Vector2(200, 22)
	base_health_bar.position = Vector2(600, 28)
	var bstyle = StyleBoxFlat.new()
	bstyle.bg_color = Color(0.3, 0.08, 0.08)
	bstyle.corner_radius_top_left = 4; bstyle.corner_radius_top_right = 4
	bstyle.corner_radius_bottom_left = 4; bstyle.corner_radius_bottom_right = 4
	base_health_bar.add_theme_stylebox_override("background", bstyle)
	var fstyle = StyleBoxFlat.new()
	fstyle.bg_color = Color(0.2, 0.9, 0.2)
	fstyle.corner_radius_top_left = 4; fstyle.corner_radius_top_right = 4
	fstyle.corner_radius_bottom_left = 4; fstyle.corner_radius_bottom_right = 4
	base_health_bar.add_theme_stylebox_override("fill", fstyle)
	panel.add_child(base_health_bar)

	# 标题
	var title = Label.new()
	title.text = "🌿 塔防大战"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.6, 0.9, 0.4))
	title.position = Vector2(205, 26)
	title.size = Vector2(180, 24)
	panel.add_child(title)

	# 状态标签（居中大字）
	state_label = Label.new()
	state_label.text = ""
	state_label.add_theme_font_size_override("font_size", 40)
	state_label.add_theme_color_override("font_color", Color.YELLOW)
	state_label.position = Vector2(250, 260)
	state_label.size = Vector2(500, 60)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(state_label)

	# 开始按钮
	start_button = Button.new()
	start_button.text = "⚔ 开始游戏"
	start_button.position = Vector2(830, 14)
	start_button.size = Vector2(150, 44)
	var bstyle2 = StyleBoxFlat.new()
	bstyle2.bg_color = Color(0.15, 0.5, 0.15)
	bstyle2.corner_radius_top_left = 8; bstyle2.corner_radius_top_right = 8
	bstyle2.corner_radius_bottom_left = 8; bstyle2.corner_radius_bottom_right = 8
	start_button.add_theme_stylebox_override("normal", bstyle2)
	start_button.add_theme_font_size_override("font_size", 16)
	start_button.pressed.connect(_on_start_pressed)
	panel.add_child(start_button)

func _on_start_pressed() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.start_level(1)
		start_button.visible = false

func _on_sun_changed(new_amount: int) -> void:
	sun_label.text = str(new_amount)

func _on_wave_changed(current: int, total: int) -> void:
	wave_label.text = "波次 " + str(current) + "/" + str(total)

func _on_base_health_changed(new_health: float) -> void:
	base_health_bar.value = clamp((new_health / 100.0) * 100.0, 0.0, 100.0)

func _on_state_changed(new_state: int) -> void:
	match new_state:
		3: state_label.text = "🎉 胜利！"
		4: state_label.text = "💀 失败..."
		_: state_label.text = ""
