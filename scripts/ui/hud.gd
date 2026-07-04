# HUD - 顶部信息栏 + 胜利/失败覆盖层（美化版）
extends CanvasLayer

@onready var sun_label: Label = null
@onready var wave_label: Label = null
@onready var base_health_bar: ProgressBar = null
@onready var state_label: Label = null
@onready var start_button: Button = null
@onready var notification_label: Label = null

# 游戏结束覆盖层
var overlay_panel: Panel = null
var overlay_container: Control = null

# 菜单覆盖层
var menu_overlay: Control = null
var menu_panel: Panel = null

func _ready() -> void:
	_create_ui()
	_create_notification()
	_create_game_over_overlay()
	_create_menu_overlay()

	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.sun_changed.connect(_on_sun_changed)
		gm.base_health_changed.connect(_on_base_health_changed)
		gm.state_changed.connect(_on_state_changed)
		gm.wave_changed.connect(_on_wave_changed)
		sun_label.text = "☀ " + str(gm.sun)
		wave_label.text = "波次 0/3"

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

	# 太阳图标（简洁emoji，无嵌套面板）
	var sun_icon = Label.new()
	sun_icon.text = "☀"
	sun_icon.add_theme_font_size_override("font_size", 22)
	sun_icon.add_theme_color_override("font_color", Color(1.0, 0.85, 0.15))
	sun_icon.position = Vector2(22, 16)
	sun_icon.size = Vector2(36, 30)
	sun_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sun_icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(sun_icon)

	sun_label = Label.new()
	sun_label.text = "150"
	sun_label.add_theme_font_size_override("font_size", 26)
	sun_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	sun_label.position = Vector2(58, 18)
	sun_label.size = Vector2(126, 36)
	panel.add_child(sun_label)

	# 波次信息
	wave_label = Label.new()
	wave_label.text = "波次 0/3"
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
	start_button.position = Vector2(815, 14)
	start_button.size = Vector2(130, 44)
	var bstyle2 = StyleBoxFlat.new()
	bstyle2.bg_color = Color(0.15, 0.5, 0.15)
	bstyle2.corner_radius_top_left = 8; bstyle2.corner_radius_top_right = 8
	bstyle2.corner_radius_bottom_left = 8; bstyle2.corner_radius_bottom_right = 8
	start_button.add_theme_stylebox_override("normal", bstyle2)
	start_button.add_theme_font_size_override("font_size", 14)
	start_button.pressed.connect(_on_start_pressed)
	panel.add_child(start_button)

	# 菜单按钮
	var menu_btn = Button.new()
	menu_btn.text = "☰ 菜单"
	menu_btn.position = Vector2(948, 14)
	menu_btn.size = Vector2(44, 44)
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = Color(0.2, 0.18, 0.12)
	menu_style.corner_radius_top_left = 8; menu_style.corner_radius_top_right = 8
	menu_style.corner_radius_bottom_left = 8; menu_style.corner_radius_bottom_right = 8
	menu_btn.add_theme_stylebox_override("normal", menu_style)
	menu_btn.add_theme_font_size_override("font_size", 18)
	menu_btn.pressed.connect(_on_menu_pressed)
	panel.add_child(menu_btn)

# ===== 波次通知横幅 =====

func _create_notification() -> void:
	notification_label = Label.new()
	notification_label.text = ""
	notification_label.add_theme_font_size_override("font_size", 32)
	notification_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.1))
	notification_label.position = Vector2(200, 240)
	notification_label.size = Vector2(600, 50)
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.visible = false
	add_child(notification_label)

func show_notification(text: String) -> void:
	if notification_label:
		notification_label.text = text
		notification_label.visible = true
		# 2秒后自动隐藏
		var t = create_tween()
		t.tween_interval(2.0)
		t.tween_callback(func(): notification_label.visible = false)

# ===== 游戏结束覆盖层 =====

func _create_game_over_overlay() -> void:
	overlay_container = Control.new()
	overlay_container.visible = false
	overlay_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay_container)

	# 半透明黑色背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_container.add_child(bg)

	# 中央面板
	overlay_panel = Panel.new()
	overlay_panel.size = Vector2(400, 380)
	overlay_panel.position = Vector2(300, 140)
	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.1, 0.08, 0.05, 0.95)
	pstyle.corner_radius_top_left = 16; pstyle.corner_radius_top_right = 16
	pstyle.corner_radius_bottom_left = 16; pstyle.corner_radius_bottom_right = 16
	pstyle.border_width_left = 3; pstyle.border_width_right = 3
	pstyle.border_width_top = 3; pstyle.border_width_bottom = 3
	pstyle.border_color = Color(0.5, 0.4, 0.2)
	overlay_panel.add_theme_stylebox_override("panel", pstyle)
	overlay_container.add_child(overlay_panel)

func _show_game_over(victory: bool) -> void:
	# 清空旧内容
	for child in overlay_panel.get_children():
		child.queue_free()

	# 向日葵图标（胜利）或骷髅（失败）
	var icon_label = Label.new()
	if victory:
		icon_label.text = "🌻"
	else:
		icon_label.text = "💀"
	icon_label.add_theme_font_size_override("font_size", 80)
	icon_label.position = Vector2(160, 20)
	icon_label.size = Vector2(80, 80)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_panel.add_child(icon_label)

	# 标题
	var title_label = Label.new()
	if victory:
		title_label.text = "🎉 胜利！"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	else:
		title_label.text = "💀 失败..."
		title_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.position = Vector2(0, 105)
	title_label.size = Vector2(400, 50)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_panel.add_child(title_label)

	# 副标题
	var sub = Label.new()
	sub.text = "所有波次已清除！" if victory else "基地被摧毁了..."
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	sub.position = Vector2(0, 155)
	sub.size = Vector2(400, 24)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_panel.add_child(sub)

	# 重新开始按钮
	var restart_btn = _make_big_button("🔄 重新开始", Color(0.15, 0.5, 0.15), Vector2(100, 200))
	restart_btn.pressed.connect(_on_restart_pressed)
	overlay_panel.add_child(restart_btn)

	# 退出游戏按钮
	var quit_btn = _make_big_button("🚪 退出游戏", Color(0.5, 0.15, 0.15), Vector2(100, 270))
	quit_btn.pressed.connect(_on_quit_pressed)
	overlay_panel.add_child(quit_btn)

	overlay_container.visible = true

# ===== 菜单覆盖层 =====

func _create_menu_overlay() -> void:
	menu_overlay = Control.new()
	menu_overlay.visible = false
	menu_overlay.process_mode = Node.PROCESS_MODE_ALWAYS  # 暂停时仍可操作
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_overlay)

	# 半透明黑色背景
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(bg)

	# 中央面板
	menu_panel = Panel.new()
	menu_panel.size = Vector2(360, 300)
	menu_panel.position = Vector2(320, 170)
	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(0.12, 0.09, 0.05, 0.95)
	pstyle.corner_radius_top_left = 16; pstyle.corner_radius_top_right = 16
	pstyle.corner_radius_bottom_left = 16; pstyle.corner_radius_bottom_right = 16
	pstyle.border_width_left = 3; pstyle.border_width_right = 3
	pstyle.border_width_top = 3; pstyle.border_width_bottom = 3
	pstyle.border_color = Color(0.5, 0.4, 0.2)
	menu_panel.add_theme_stylebox_override("panel", pstyle)
	menu_overlay.add_child(menu_panel)

	# 标题
	var title = Label.new()
	title.text = "📋 游戏菜单"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	title.position = Vector2(0, 20)
	title.size = Vector2(360, 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_panel.add_child(title)

	# 全屏按钮
	var fs_btn = _make_menu_button("🖥 切换全屏", Vector2(60, 80))
	fs_btn.pressed.connect(_on_fullscreen_toggle)
	menu_panel.add_child(fs_btn)

	# 重新开始按钮
	var restart_btn = _make_menu_button("🔄 重新开始", Vector2(60, 145))
	restart_btn.pressed.connect(_on_menu_restart)
	menu_panel.add_child(restart_btn)

	# 退出游戏按钮
	var quit_btn = _make_menu_button("🚪 退出游戏", Vector2(60, 210))
	quit_btn.pressed.connect(_on_menu_quit)
	menu_panel.add_child(quit_btn)

	# 关闭按钮（右上角X）
	var close_btn = Button.new()
	close_btn.text = "✕"
	close_btn.position = Vector2(320, 6)
	close_btn.size = Vector2(32, 32)
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.4, 0.1, 0.1)
	close_style.corner_radius_top_left = 6; close_style.corner_radius_top_right = 6
	close_style.corner_radius_bottom_left = 6; close_style.corner_radius_bottom_right = 6
	close_btn.add_theme_stylebox_override("normal", close_style)
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.pressed.connect(_close_menu)
	menu_panel.add_child(close_btn)

func _make_menu_button(text: String, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(240, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.16, 0.1)
	style.corner_radius_top_left = 10; style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10; style.corner_radius_bottom_right = 10
	style.border_width_left = 1; style.border_width_right = 1
	style.border_width_top = 1; style.border_width_bottom = 1
	style.border_color = Color(0.4, 0.35, 0.2)
	btn.add_theme_stylebox_override("normal", style)
	var hstyle = StyleBoxFlat.new()
	hstyle.bg_color = Color(0.3, 0.24, 0.15)
	hstyle.corner_radius_top_left = 10; hstyle.corner_radius_top_right = 10
	hstyle.corner_radius_bottom_left = 10; hstyle.corner_radius_bottom_right = 10
	hstyle.border_width_left = 1; hstyle.border_width_right = 1
	hstyle.border_width_top = 1; hstyle.border_width_bottom = 1
	hstyle.border_color = Color(0.6, 0.5, 0.3)
	btn.add_theme_stylebox_override("hover", hstyle)
	btn.add_theme_font_size_override("font_size", 17)
	return btn

func _make_big_button(text: String, color: Color, pos: Vector2) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.position = pos
	btn.size = Vector2(200, 50)
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10; style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10; style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", style)
	var hstyle = StyleBoxFlat.new()
	hstyle.bg_color = color.lightened(0.2)
	hstyle.corner_radius_top_left = 10; hstyle.corner_radius_top_right = 10
	hstyle.corner_radius_bottom_left = 10; hstyle.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("hover", hstyle)
	btn.add_theme_font_size_override("font_size", 18)
	return btn

# ===== 回调 =====

func _on_start_pressed() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.start_level(1)
		start_button.visible = false

func _on_restart_pressed() -> void:
	overlay_container.visible = false
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.restart_game()
	start_button.visible = true
	sun_label.text = "150"
	wave_label.text = "波次 0/3"
	base_health_bar.value = 100.0

func _on_quit_pressed() -> void:
	get_tree().quit()

# ===== 菜单回调 =====

func _on_menu_pressed() -> void:
	if menu_overlay.visible:
		_close_menu()
		return
	# 暂停游戏并显示菜单
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm and gm.current_state == 1:  # PLAYING
		get_tree().paused = true
	menu_overlay.visible = true

func _close_menu() -> void:
	menu_overlay.visible = false
	get_tree().paused = false

func _on_fullscreen_toggle() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_menu_restart() -> void:
	get_tree().paused = false
	menu_overlay.visible = false
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.restart_game()
	start_button.visible = true
	sun_label.text = "150"
	wave_label.text = "波次 0/3"
	base_health_bar.value = 100.0

func _on_menu_quit() -> void:
	get_tree().quit()

# ===== HUD 回调 =====

func _on_sun_changed(new_amount: int) -> void:
	sun_label.text = str(new_amount)

func _on_base_health_changed(new_health: float) -> void:
	base_health_bar.value = clamp(new_health, 0.0, 100.0)

func _on_state_changed(new_state: int) -> void:
	match new_state:
		3:  # VICTORY
			state_label.text = ""
			_show_game_over(true)
		4:  # DEFEAT
			state_label.text = ""
			_show_game_over(false)
		_:  # READY or PLAYING
			state_label.text = ""
			if overlay_container:
				overlay_container.visible = false

func _on_wave_changed(current: int, total: int) -> void:
	if wave_label:
		wave_label.text = "波次 " + str(current) + "/" + str(total)
