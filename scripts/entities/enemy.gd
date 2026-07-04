# Enemy - 敌人基类
class_name Enemy
extends Node2D

# 基本属性
var enemy_type: int = -1
var enemy_name: String = ""
var health: float = 100.0
var max_health: float = 100.0
var speed: float = 20.0
var base_speed: float = 20.0
var damage: float = 20.0
var reward: int = 25

# 运行时状态
var row: int = -1
var col: int = -1
var is_alive: bool = true
var is_slowed: bool = false
var slow_timer: float = 0.0

# 攻击状态
var is_attacking: bool = false
var attack_timer: float = 0.0

@onready var body: ColorRect = null
@onready var game_manager: Node = null

func _ready() -> void:
	add_to_group("enemies")
	game_manager = get_node_or_null("/root/Main/GameManager")

func setup(type: int, spawn_row: int) -> void:
	enemy_type = type
	row = spawn_row
	var data = EnemyData.get_enemy(type)
	if data.is_empty():
		return

	enemy_name = data.get("name", "???")
	health = data.get("health", 100.0)
	max_health = health
	speed = data.get("speed", 20.0)
	base_speed = speed
	damage = data.get("damage", 20.0)
	reward = data.get("reward", 25)

	_create_placeholder()

func _create_placeholder() -> void:
	for child in get_children():
		if child is ColorRect and child != body:
			child.queue_free()

	var data = EnemyData.get_enemy(enemy_type)
	var color = data.get("color", Color.GRAY)

	body = ColorRect.new()
	body.color = color
	body.size = Vector2(40, 60)
	body.position = Vector2(-20, -50)
	add_child(body)

	# 血量条背景
	var hp_bg = ColorRect.new()
	hp_bg.color = Color(0.3, 0.3, 0.3)
	hp_bg.size = Vector2(50, 6)
	hp_bg.position = Vector2(-25, -60)
	add_child(hp_bg)

	# 血量条
	var hp_fill = ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(1, 0, 0)
	hp_fill.size = Vector2(50, 6)
	hp_fill.position = Vector2(-25, -60)
	add_child(hp_fill)

	# 名字标签
	var label = Label.new()
	label.text = enemy_name
	label.add_theme_font_size_override("font_size", 9)
	label.position = Vector2(-25, -75)
	label.size = Vector2(50, 15)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)

func _process(delta: float) -> void:
	if not is_alive:
		return

	# 减速计时器
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			_remove_slow()

	# 到达底线后攻击
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			_deal_damage_to_base()
			attack_timer = 1.0
		return

	# 向左移动
	position.x -= speed * delta

	# 更新所在列
	col = int((position.x - 40.0) / 100.0)

	# 到达左边界
	if position.x <= 40.0:
		_on_reach_base()

func take_damage(amount: float) -> void:
	if not is_alive:
		return
	health -= amount
	_update_hp_bar()
	if body:
		body.modulate = Color.RED
		await get_tree().create_timer(0.08).timeout
		if body:
			body.modulate = Color.WHITE
	if health <= 0:
		_die()

func apply_slow(amount: float, duration: float) -> void:
	speed = base_speed * amount
	is_slowed = true
	slow_timer = duration
	if body:
		body.color = Color(0.4, 0.6, 1.0)

func _remove_slow() -> void:
	speed = base_speed
	is_slowed = false
	if body:
		var data = EnemyData.get_enemy(enemy_type)
		body.color = data.get("color", Color.GRAY)

func _update_hp_bar() -> void:
	var hp_fill = get_node_or_null("HPFill")
	if hp_fill:
		var ratio = clamp(health / max_health, 0.0, 1.0)
		hp_fill.size.x = 50.0 * ratio

func _on_reach_base() -> void:
	is_attacking = true
	attack_timer = 1.0

func _deal_damage_to_base() -> void:
	if game_manager and game_manager.has_method("damage_base"):
		game_manager.damage_base(damage)

func _die() -> void:
	is_alive = false
	if game_manager and game_manager.has_method("add_sun_reward"):
		game_manager.add_sun_reward(reward)
	queue_free()
