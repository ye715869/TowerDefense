# Projectile - 子弹/投射物
class_name Projectile
extends Area2D

var speed: float = 300.0
var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var slow_amount: float = 0.0     # 减速量（0=不减速）
var slow_duration: float = 0.0   # 减速持续时间

@onready var sprite: ColorRect = null

func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)
	_create_sprite()

func _create_sprite() -> void:
	sprite = ColorRect.new()
	sprite.color = Color.GREEN if slow_amount == 0 else Color(0.3, 0.7, 1.0)
	sprite.size = Vector2(12, 12)
	sprite.position = Vector2(-6, -6)
	add_child(sprite)

func setup(proj_damage: float, proj_speed: float, proj_dir: Vector2, slow_amt: float = 0.0, slow_dur: float = 0.0) -> void:
	damage = proj_damage
	speed = proj_speed
	direction = proj_dir
	slow_amount = slow_amt
	slow_duration = slow_dur

func _process(delta: float) -> void:
	position += direction * speed * delta
	# 超出屏幕自动销毁
	if position.x > 1200 or position.x < -100:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		if slow_amount > 0:
			body.apply_slow(slow_amount, slow_duration)
		queue_free()
