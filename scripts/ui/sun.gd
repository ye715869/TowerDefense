# Sun - 阳光实体（放大版，白色光晕，可点击收集）
class_name Sun
extends Area2D

var amount: int = 25
var fall_speed: float = 80.0
var lifetime: float = 5.0
var collected: bool = false
var target_y: float = 0.0
var anim_time: float = 0.0

func _ready() -> void:
	add_to_group("suns")
	target_y = randf_range(250, 450)
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	if not collected:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _process(delta: float) -> void:
	if collected:
		# 飞行中持续动画
		anim_time += delta
		queue_redraw()
		return
	anim_time += delta
	if position.y < target_y:
		position.y += fall_speed * delta
		if position.y >= target_y: position.y = target_y
	lifetime -= delta
	if lifetime <= 1.0:
		modulate.a = sin(anim_time * 10.0) * 0.5 + 0.5
	if lifetime <= 0: queue_free()
	queue_redraw()

func _on_input_event(_vp: Node, event: InputEvent, _si: int) -> void:
	if collected: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT: _collect()

func _collect() -> void:
	collected = true
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	# 禁用碰撞体防止重复点击
	var col_shape = get_node_or_null("CollisionShape2D")
	if col_shape:
		col_shape.set_deferred("disabled", true)

	# 目标：左上角阳光计数器位置（屏幕坐标 → 世界坐标）
	var target_screen = Vector2(70, 35)
	var canvas_tf = get_viewport().get_canvas_transform()
	var target_world = canvas_tf.affine_inverse() * target_screen

	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target_world, 0.35).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(0.25, 0.25), 0.35).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(_finish_collect)

func _finish_collect() -> void:
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm: gm.add_sun(amount)
	queue_free()

func _draw() -> void:
	var pulse = 1.0 + sin(anim_time * 3.0) * 0.1

	# 最外层白色光晕
	for i in range(3):
		var r = (22.0 + i * 7) * pulse
		var a = 0.08 - i * 0.02
		draw_circle(Vector2.ZERO, r, Color(1.0, 1.0, 1.0, a))

	# 中层金色光晕
	for i in range(3):
		var r = (16.0 + i * 6) * pulse
		var a = 0.18 - i * 0.05
		draw_circle(Vector2.ZERO, r, Color(1.0, 0.9, 0.1, a))

	# 主体（放大）
	draw_circle(Vector2.ZERO, 20 * pulse, Color(1.0, 0.85, 0.1))
	# 高光
	draw_circle(Vector2(-4, -4), 7, Color(1.0, 1.0, 0.6, 0.45))
	draw_circle(Vector2(-2, -2), 3, Color(1.0, 1.0, 0.9, 0.3))

	# 光芒射线（更长更明显）
	for i in range(8):
		var angle = i * PI / 4 + anim_time * 0.4
		var inner = 14.0
		var outer = 19.0 + sin(anim_time * 2.0 + i) * 3.0
		draw_line(
			Vector2(cos(angle) * inner, sin(angle) * inner),
			Vector2(cos(angle) * outer, sin(angle) * outer),
			Color(1, 1, 0.4, 0.5), 2.5
		)
