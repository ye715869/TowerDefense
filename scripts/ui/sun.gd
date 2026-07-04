# Sun - 阳光实体（可点击收集）
class_name Sun
extends Area2D

var amount: int = 25
var fall_speed: float = 80.0
var lifetime: float = 5.0       # 存在5秒后消失
var collected: bool = false
var target_y: float = 0.0       # 落地目标 y 坐标

@onready var sprite: ColorRect = null
@onready var lifetime_timer: float = 0.0

func _ready() -> void:
	add_to_group("suns")
	_create_sprite()
	lifetime_timer = lifetime
	input_event.connect(_on_input_event)

	# 随机落地位置
	target_y = randf_range(250, 450)

func _create_sprite() -> void:
	sprite = ColorRect.new()
	sprite.color = Color(1.0, 0.9, 0.2)
	sprite.size = Vector2(30, 30)
	sprite.position = Vector2(-15, -15)
	add_child(sprite)

	# 简单光晕
	var glow = ColorRect.new()
	glow.color = Color(1.0, 1.0, 0.5, 0.3)
	glow.size = Vector2(40, 40)
	glow.position = Vector2(-20, -20)
	add_child(glow)

	# 碰撞区域
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	add_child(collision)

func _process(delta: float) -> void:
	if collected:
		return

	# 下落动画
	if position.y < target_y:
		position.y += fall_speed * delta
		if position.y >= target_y:
			position.y = target_y

	# 闪烁消失
	lifetime_timer -= delta
	if lifetime_timer <= 1.0:
		# 最后1秒闪烁
		var flash = sin(lifetime_timer * 10.0) > 0
		visible = flash

	if lifetime_timer <= 0:
		queue_free()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if collected:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_collect()

func _collect() -> void:
	collected = true
	var gm = get_node_or_null("/root/Main/GameManager")
	if gm:
		gm.add_sun(amount)
	queue_free()
