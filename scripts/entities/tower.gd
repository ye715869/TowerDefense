# Tower - 防御塔基类（美化版）
class_name Tower
extends Node2D

var plant_type: int = -1
var tower_name: String = ""
var health: float = 100.0
var max_health: float = 100.0
var damage: float = 0.0
var attack_speed: float = 0.0
var attack_range: float = 0.0
var cost: int = 0
var sun_production: int = 0
var sun_interval: float = 0.0

var row: int = -1
var col: int = -1
var attack_timer: float = 0.0
var sun_timer: float = 0.0
var is_alive: bool = true
var is_one_shot: bool = false
var slow_amount: float = 0.0
var slow_duration: float = 0.0
var anim_time: float = 0.0

@onready var grid_ref: Node2D = null

func _ready() -> void:
	add_to_group("towers")

func setup(type: int, grid_node: Node2D) -> void:
	plant_type = type
	grid_ref = grid_node
	var data = GameData.get_plant(type)
	if data.is_empty(): return
	tower_name = data.get("name", "???")
	health = data.get("health", 100.0)
	max_health = health
	damage = data.get("damage", 0.0)
	attack_speed = data.get("attack_speed", 0.0)
	attack_range = data.get("range", 0)
	cost = data.get("cost", 0)
	sun_production = data.get("sun_production", 0)
	sun_interval = data.get("sun_interval", 0.0)
	slow_amount = data.get("slow_amount", 0.0)
	slow_duration = data.get("slow_duration", 0.0)
	is_one_shot = data.get("one_shot", false)
	attack_timer = attack_speed
	sun_timer = sun_interval

func _process(delta: float) -> void:
	if not is_alive: return
	anim_time += delta
	if sun_production > 0 and sun_interval > 0:
		sun_timer -= delta
		if sun_timer <= 0:
			_produce_sun()
			sun_timer = sun_interval
	if damage > 0 and attack_speed > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			_attack()
			attack_timer = attack_speed
	queue_redraw()

func _attack() -> void: pass

func _produce_sun() -> void:
	if sun_production <= 0: return
	if grid_ref and grid_ref.has_method("get_sun_manager"):
		var sm = grid_ref.get_sun_manager()
		if sm: sm.add_sun(sun_production, global_position)

func take_damage(amount: float) -> void:
	if not is_alive: return
	health -= amount
	# 闪白效果
	modulate = Color(2, 2, 2)
	var tw = create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.15)
	if health <= 0: _die()

func _die() -> void:
	is_alive = false
	if grid_ref and row >= 0 and col >= 0:
		grid_ref.remove_plant(row, col)
	queue_free()

func get_sun_manager() -> Node:
	return get_node_or_null("/root/Main/GameManager/SunManager")

# ============== 通用绘制 ==============

func _draw() -> void:
	if not is_alive: return
	var data = GameData.get_plant(plant_type)
	var col = data.get("color", Color.WHITE)
	_draw_plant_body(col)
	_draw_hp_bar()
	_draw_label()

func _draw_plant_body(color: Color) -> void:
	# 圆形主体（花盆）
	draw_circle(Vector2.ZERO, 28, Color(0.45, 0.28, 0.15))  # 花盆
	draw_circle(Vector2(0, -6), 24, color)                    # 植物头部
	# 高光
	draw_circle(Vector2(-8, -12), 6, Color(1, 1, 1, 0.25))
	# 眼睛
	draw_circle(Vector2(-8, -10), 4, Color.WHITE)
	draw_circle(Vector2(6, -10), 4, Color.WHITE)
	draw_circle(Vector2(-7, -9), 2, Color.BLACK)
	draw_circle(Vector2(7, -9), 2, Color.BLACK)
	# 嘴
	var mouth_y = -2
	draw_arc(Vector2(0, mouth_y), 8, PI * 0.1, PI * 0.9, 6, Color(0.1, 0.1, 0.1), 1.5)
	# 茎
	draw_rect(Rect2(-3, 18, 6, 10), Color(0.2, 0.6, 0.15))
	# 小叶子
	draw_circle(Vector2(6, 22), 5, Color(0.25, 0.65, 0.2))

func _draw_hp_bar() -> void:
	if max_health <= 0: return
	var ratio = clamp(health / max_health, 0.0, 1.0)
	var bar_w = 52.0
	var bar_y = -38
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, 5), Color(0.1, 0.1, 0.1, 0.8))
	var hp_col = Color.GREEN if ratio > 0.5 else (Color.YELLOW if ratio > 0.25 else Color.RED)
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w * ratio, 5), hp_col)

func _draw_label() -> void:
	var font = ThemeDB.fallback_font
	if not font: return
	var fsize = 10
	draw_string(font, Vector2(-24, 34), tower_name, HORIZONTAL_ALIGNMENT_CENTER, 50, fsize)
