# Sun - 阳光实体（美化版，可点击收集）
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

func _process(delta: float) -> void:
	if collected: return
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
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm: gm.add_sun(amount)
	# 收集动画
	var t = Node2D.new()
	t.position = position
	get_parent().add_child(t)
	var label = Label.new()
	label.text = "+" + str(amount)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.2))
	label.position = Vector2(-20, -20)
	t.add_child(label)
	var tw = t.create_tween()
	tw.tween_property(t, "position:y", position.y - 50, 0.6)
	tw.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tw.tween_callback(t.queue_free)
	queue_free()

func _draw() -> void:
	var pulse = 1.0 + sin(anim_time * 3.0) * 0.1
	# 外发光
	for i in range(3):
		var r = (14.0 + i * 8) * pulse
		var a = 0.15 - i * 0.04
		draw_circle(Vector2.ZERO, r, Color(1.0, 0.9, 0.1, a))
	# 主体
	draw_circle(Vector2.ZERO, 13 * pulse, Color(1.0, 0.85, 0.1))
	draw_circle(Vector2(-3, -3), 5, Color(1.0, 1.0, 0.5, 0.4))
	# 光芒射线
	for i in range(8):
		var angle = i * PI / 4 + anim_time * 0.5
		var inner = 9.0
		var outer = 12.0 + sin(anim_time * 2.0) * 2.0
		draw_line(Vector2(cos(angle) * inner, sin(angle) * inner), Vector2(cos(angle) * outer, sin(angle) * outer), Color(1, 1, 0.3, 0.4), 2)
