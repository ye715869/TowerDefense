# Enemy - 敌人基类（美化版）
class_name Enemy
extends Node2D

var enemy_type: int = -1
var enemy_name: String = ""
var health: float = 100.0
var max_health: float = 100.0
var speed: float = 20.0
var base_speed: float = 20.0
var damage: float = 20.0
var reward: int = 25
var row: int = -1
var col: int = -1
var is_alive: bool = true
var is_slowed: bool = false
var slow_timer: float = 0.0
var is_attacking: bool = false
var attack_timer: float = 0.0
var anim_time: float = 0.0

@onready var game_manager: Node = null

func _ready() -> void:
	add_to_group("enemies")
	game_manager = get_node_or_null("/root/Main/GameManager")

func setup(type: int, spawn_row: int) -> void:
	enemy_type = type
	row = spawn_row
	var data = EnemyData.get_enemy(type)
	if data.is_empty(): return
	enemy_name = data.get("name", "???")
	health = data.get("health", 100.0)
	max_health = health
	speed = data.get("speed", 20.0)
	base_speed = speed
	damage = data.get("damage", 20.0)
	reward = data.get("reward", 25)

func _process(delta: float) -> void:
	if not is_alive: return
	anim_time += delta
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0: _remove_slow()
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			_deal_damage_to_base()
			attack_timer = 1.0
		queue_redraw()
		return
	position.x -= speed * delta
	col = int((position.x - 40.0) / 100.0)
	if position.x <= 40.0: _on_reach_base()
	queue_redraw()

func take_damage(amount: float) -> void:
	if not is_alive: return
	health -= amount
	modulate = Color(3, 0.5, 0.5)
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.12)
	if health <= 0: _die()

func apply_slow(amount: float, duration: float) -> void:
	speed = base_speed * amount
	is_slowed = true
	slow_timer = duration

func _remove_slow() -> void:
	speed = base_speed
	is_slowed = false

func _on_reach_base() -> void:
	is_attacking = true
	attack_timer = 1.0

func _deal_damage_to_base() -> void:
	if game_manager and game_manager.has_method("damage_base"):
		game_manager.damage_base(damage)

func _die() -> void:
	is_alive = false
	# 死亡奖励
	if game_manager and game_manager.has_method("add_sun_reward"):
		game_manager.add_sun_reward(reward)
	# 死亡粒子效果
	_spawn_death_effect()
	queue_free()

func _spawn_death_effect() -> void:
	var particles = []
	for i in range(6):
		var p = ColorRect.new()
		p.color = Color(1, 0.8, 0.2, 0.8)
		p.size = Vector2(6, 6)
		p.position = Vector2(-3, -3)
		var t = Node2D.new()
		t.position = position
		t.add_child(p)
		get_parent().add_child(t)
		var tw = t.create_tween()
		tw.tween_property(t, "position", position + Vector2(randf_range(-50, 50), randf_range(-50, -10)), 0.5)
		tw.parallel().tween_property(p, "modulate:a", 0.0, 0.5)
		tw.tween_callback(t.queue_free)
		particles.append(t)

# ============== 绘制 ==============

func _draw() -> void:
	if not is_alive: return
	var data = EnemyData.get_enemy(enemy_type)
	var color = data.get("color", Color.GRAY)
	if is_slowed: color = Color(0.4, 0.6, 1.0)
	_draw_body(color)
	_draw_hp_bar()
	_draw_label()

func _draw_body(color: Color) -> void:
	var bob = sin(anim_time * 4.0) * 2.0  # 走路晃动
	var lean = sin(anim_time * 3.0) * 3.0  # 前倾角度

	if is_attacking:
		# 攻击姿态 — 向前挥动
		var swing = sin(anim_time * 5.0) * 8.0
		_draw_zombie_shape(0, 0, color, swing)
	else:
		_draw_zombie_shape(0, bob, color, lean)

func _draw_zombie_shape(ox: float, oy: float, color: Color, lean: float) -> void:
	# 身体
	draw_rect(Rect2(-14 + ox, -30 + oy, 28, 35), color.darkened(0.3))
	# 头部
	draw_circle(Vector2(ox, -34 + oy), 14, color)
	# 眼睛（红色，更可怕）
	draw_circle(Vector2(-5 + ox, -37 + oy), 3.5, Color.WHITE)
	draw_circle(Vector2(5 + ox, -37 + oy), 3.5, Color.WHITE)
	draw_circle(Vector2(-4 + ox, -36 + oy), 2, Color(0.9, 0.1, 0.1))
	draw_circle(Vector2(6 + ox, -36 + oy), 2, Color(0.9, 0.1, 0.1))
	# 牙齿
	for i in range(3):
		draw_rect(Rect2(-7 + i * 5 + ox, -24 + oy, 3, 5), Color.WHITE)
	# 手臂（伸向前方）
	var arm_x = 16 + lean * 0.3
	draw_rect(Rect2(arm_x + ox, -20 + oy, 12, 6), color.lightened(0.1))
	# 腿（走路动画）
	var leg_spread = sin(anim_time * 5.0) * 5.0
	draw_rect(Rect2(-10 + leg_spread + ox, 5 + oy, 8, 12), color.darkened(0.4))
	draw_rect(Rect2(2 - leg_spread + ox, 5 + oy, 8, 12), color.darkened(0.4))

func _draw_hp_bar() -> void:
	var ratio = clamp(health / max_health, 0.0, 1.0)
	var bw = 46.0
	var by = -50
	draw_rect(Rect2(-bw / 2, by, bw, 4), Color(0.1, 0.1, 0.1, 0.8))
	draw_rect(Rect2(-bw / 2, by, bw * ratio, 4), Color(0.85, 0.15, 0.15))

func _draw_label() -> void:
	var font = ThemeDB.fallback_font
	if not font: return
	draw_string(font, Vector2(-28, -56), enemy_name, HORIZONTAL_ALIGNMENT_CENTER, 56, 9)
