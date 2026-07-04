# HUD - 顶部信息栏 + 开始按钮
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
		# 初始化阳光显示
		sun_label.text = "☀ " + str(gm.sun)

func _create_ui() -> void:
	# 顶部背景条
	var bg = ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.1, 0.8)
	bg.size = Vector2(1000, 70)
	bg.position = Vector2(0, 0)
	add_child(bg)

	# 阳光图标
	var sun_icon = ColorRect.new()
	sun_icon.color = Color(1.0, 0.9, 0.2)
	sun_icon.size = Vector2(36, 36)
	sun_icon.position = Vector2(20, 17)
	add_child(sun_icon)

	sun_label = Label.new()
	sun_label.text = "☀ 150"
	sun_label.add_theme_font_size_override("font_size", 28)
	sun_label.add_theme_color_override("font_color", Color.WHITE)
	sun_label.position = Vector2(65, 17)
	sun_label.size = Vector2(150, 36)
	add_child(sun_label)

	# 波次信息
	wave_label = Label.new()
	wave_label.text = "波次: 0/0"
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.add_theme_color_override("font_color", Color.WHITE)
	wave_label.position = Vector2(380, 20)
	wave_label.size = Vector2(200, 30)
	add_child(wave_label)

	# 基地血量
	var base_label = Label.new()
	base_label.text = "基地"
	base_label.add_theme_font_size_override("font_size", 14)
	base_label.add_theme_color_override("font_color", Color.WHITE)
	base_label.position = Vector2(600, 10)
	base_label.size = Vector2(60, 20)
	add_child(base_label)

	base_health_bar = ProgressBar.new()
	base_health_bar.value = 100.0
	base_health_bar.size = Vector2(200, 20)
	base_health_bar.position = Vector2(600, 30)
	add_child(base_health_bar)

	# 状态文字（胜利/失败）
	state_label = Label.new()
	state_label.text = ""
	state_label.add_theme_font_size_override("font_size", 36)
	state_label.add_theme_color_override("font_color", Color.YELLOW)
	state_label.position = Vector2(300, 250)
	state_label.size = Vector2(400, 60)
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(state_label)

	# 开始按钮
	start_button = Button.new()
	start_button.text = "开始游戏"
	start_button.position = Vector2(830, 12)
	start_button.size = Vector2(140, 46)
	start_button.pressed.connect(_on_start_pressed)
	add_child(start_button)

	# 下一波按钮
	var next_button = Button.new()
	next_button.name = "NextWaveButton"
	next_button.text = "下一波"
	next_button.position = Vector2(830, 120)
	next_button.size = Vector2(140, 36)
	next_button.pressed.connect(_on_next_wave_pressed)
	add_child(next_button)

func _on_start_pressed() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.start_level(1)
		start_button.visible = false

func _on_next_wave_pressed() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and gm.current_state == gm.GameState.PLAYING:
		gm.next_wave()

func _on_sun_changed(new_amount: int) -> void:
	sun_label.text = "☀ " + str(new_amount)

func _on_wave_changed(current: int, total: int) -> void:
	wave_label.text = "波次: " + str(current) + "/" + str(total)

func _on_base_health_changed(new_health: float) -> void:
	base_health_bar.value = clamp((new_health / 100.0) * 100.0, 0.0, 100.0)

func _on_state_changed(new_state: int) -> void:
	match new_state:
		0: state_label.text = "准备开始"
		1: state_label.text = ""
		3:
			state_label.text = "🎉 胜利！"
			state_label.add_theme_color_override("font_color", Color.GREEN)
		4:
			state_label.text = "💀 失败..."
			state_label.add_theme_color_override("font_color", Color.RED)
