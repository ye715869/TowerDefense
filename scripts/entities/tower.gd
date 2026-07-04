# Tower - 防御塔基类（PvZ风格绘制）
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

var grid_ref: Node2D = null

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

# ============== PvZ 风格绘制 ==============

func _draw() -> void:
	if not is_alive: return
	var data = GameData.get_plant(plant_type)
	var col = data.get("color", Color.WHITE)
	_draw_plant_body(col)
	_draw_hp_bar()
	_draw_label()

func _draw_plant_body(_color: Color) -> void:
	# 花盆（所有植物共用）
	_draw_pot()

	# 按植物类型绘制不同外观
	match plant_type:
		GameData.PlantType.SUNFLOWER:
			_draw_sunflower_body()
		GameData.PlantType.PEASHOOTER:
			_draw_peashooter_body()
		GameData.PlantType.SNOW_PEA:
			_draw_snowpea_body()
		GameData.PlantType.WALL_NUT:
			_draw_wallnut_body()
		GameData.PlantType.CHERRY_BOMB:
			_draw_cherrybomb_body()
		_:
			# 降级：通用圆形植物
			draw_circle(Vector2(0, -6), 24, _color)
			draw_circle(Vector2(-8, -12), 6, Color(1, 1, 1, 0.25))
			draw_circle(Vector2(-8, -10), 4, Color.WHITE)
			draw_circle(Vector2(6, -10), 4, Color.WHITE)
			draw_circle(Vector2(-7, -9), 2, Color.BLACK)
			draw_circle(Vector2(7, -9), 2, Color.BLACK)
			draw_arc(Vector2(0, -2), 8, PI * 0.1, PI * 0.9, 6, Color(0.1, 0.1, 0.1), 1.5)

# ===== 花盆 =====
func _draw_pot() -> void:
	var pot_top = 20
	var pot_bot = 34
	var pot_color = Color(0.55, 0.35, 0.18)
	var pot_dark = Color(0.35, 0.22, 0.1)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-18, pot_top), Vector2(18, pot_top),
			Vector2(22, pot_bot), Vector2(-22, pot_bot)
		]), pot_color)
	draw_rect(Rect2(-20, pot_top - 4, 40, 8), pot_dark)
	draw_rect(Rect2(-22, pot_bot - 3, 44, 4), pot_dark)

# ===== 向日葵 =====
func _draw_sunflower_body() -> void:
	var sway = sin(anim_time * 2.5) * 3.0
	var cx = sway
	var cy = -30
	draw_line(Vector2(0, 20), Vector2(cx, cy + 15), Color(0.15, 0.5, 0.1), 5)
	draw_colored_polygon(
		PackedVector2Array([Vector2(cx, cy + 10), Vector2(cx - 14, cy + 2), Vector2(cx - 3, cy + 14)]),
		Color(0.2, 0.6, 0.15))
	draw_colored_polygon(
		PackedVector2Array([Vector2(cx, cy + 14), Vector2(cx + 14, cy + 6), Vector2(cx + 3, cy + 18)]),
		Color(0.18, 0.55, 0.12))
	var petal_count = 12
	for i in range(petal_count):
		var angle = TAU * i / petal_count + anim_time * 0.3
		var px = cx + cos(angle) * 18
		var py = cy + sin(angle) * 16
		draw_circle(Vector2(px, py), 8, Color(1.0, 0.85, 0.1) if i % 3 != 0 else Color(1.0, 0.7, 0.05))
	draw_circle(Vector2(cx, cy), 12, Color(0.45, 0.25, 0.1))
	draw_circle(Vector2(cx, cy), 9, Color(0.5, 0.3, 0.12))
	draw_circle(Vector2(cx - 4, cy - 3), 3, Color.WHITE)
	draw_circle(Vector2(cx + 4, cy - 3), 3, Color.WHITE)
	draw_circle(Vector2(cx - 3, cy - 3), 1.5, Color.BLACK)
	draw_circle(Vector2(cx + 5, cy - 3), 1.5, Color.BLACK)
	draw_arc(Vector2(cx, cy + 1), 5, PI * 0.1, PI * 0.9, 5, Color(0.1, 0.1, 0.1), 1.2)

# ===== 豌豆射手 =====
func _draw_peashooter_body() -> void:
	var sway = sin(anim_time * 3.0) * 2.0
	var cx = sway
	var cy = -28
	draw_line(Vector2(0, 20), Vector2(cx, cy + 8), Color(0.15, 0.5, 0.1), 5)
	draw_colored_polygon(
		PackedVector2Array([Vector2(cx - 4, cy - 22), Vector2(cx - 12, cy - 14), Vector2(cx, cy - 8)]),
		Color(0.2, 0.55, 0.12))
	draw_circle(Vector2(cx, cy), 18, Color(0.18, 0.7, 0.2))
	draw_circle(Vector2(cx - 2, cy - 2), 16, Color(0.22, 0.75, 0.25))
	var barrel_end = cx + 22
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx + 8, cy - 6), Vector2(barrel_end, cy - 7),
			Vector2(barrel_end, cy + 3), Vector2(cx + 8, cy + 6)
		]), Color(0.18, 0.65, 0.18))
	draw_rect(Rect2(barrel_end - 1, cy - 9, 5, 12), Color(0.15, 0.55, 0.12))
	draw_circle(Vector2(barrel_end + 3, cy - 2), 4, Color(0.1, 0.15, 0.1))
	draw_circle(Vector2(cx - 1, cy - 10), 8, Color.WHITE)
	draw_circle(Vector2(cx + 2, cy - 10), 4, Color.BLACK)
	draw_circle(Vector2(cx + 3, cy - 11), 1.5, Color.WHITE)

# ===== 冰冻射手 =====
func _draw_snowpea_body() -> void:
	var sway = sin(anim_time * 3.0) * 2.0
	var cx = sway
	var cy = -28
	draw_line(Vector2(0, 20), Vector2(cx, cy + 8), Color(0.1, 0.4, 0.25), 5)
	draw_colored_polygon(
		PackedVector2Array([Vector2(cx - 4, cy - 22), Vector2(cx - 12, cy - 14), Vector2(cx, cy - 8)]),
		Color(0.15, 0.5, 0.4))
	draw_circle(Vector2(cx, cy), 18, Color(0.2, 0.55, 0.85))
	draw_circle(Vector2(cx - 2, cy - 2), 16, Color(0.3, 0.65, 0.9))
	for i in range(3):
		var ix = cx + cos(anim_time * 4 + i * 2.1) * 14
		var iy = cy + sin(anim_time * 4 + i * 2.1) * 12
		draw_circle(Vector2(ix, iy), 3, Color(0.7, 0.9, 1.0, 0.6))
	var barrel_end = cx + 22
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(cx + 8, cy - 6), Vector2(barrel_end, cy - 7),
			Vector2(barrel_end, cy + 3), Vector2(cx + 8, cy + 6)
		]), Color(0.18, 0.5, 0.8))
	draw_rect(Rect2(barrel_end - 1, cy - 9, 5, 12), Color(0.12, 0.4, 0.7))
	draw_circle(Vector2(cx - 1, cy - 10), 8, Color.WHITE)
	draw_circle(Vector2(cx + 2, cy - 10), 4, Color(0.1, 0.2, 0.5))
	draw_circle(Vector2(cx + 3, cy - 11), 1.5, Color.WHITE)

# ===== 坚果墙 =====
func _draw_wallnut_body() -> void:
	var cx = 0
	var cy = -14
	draw_circle(Vector2(cx, cy), 24, Color(0.55, 0.35, 0.15))
	draw_circle(Vector2(cx - 2, cy - 2), 22, Color(0.65, 0.42, 0.2))
	draw_line(Vector2(cx - 6, cy - 20), Vector2(cx - 4, cy - 8), Color(0.4, 0.25, 0.1), 1.5)
	draw_line(Vector2(cx + 8, cy - 14), Vector2(cx + 4, cy - 2), Color(0.4, 0.25, 0.1), 1.5)
	draw_arc(Vector2(cx, cy - 18), 8, PI * 0.8, PI * 1.5, 5, Color(0.35, 0.2, 0.08), 1.0)
	draw_circle(Vector2(cx - 6, cy - 6), 4, Color.WHITE)
	draw_circle(Vector2(cx + 6, cy - 6), 4, Color.WHITE)
	draw_circle(Vector2(cx - 5, cy - 5), 2.5, Color.BLACK)
	draw_circle(Vector2(cx + 7, cy - 5), 2.5, Color.BLACK)
	draw_line(Vector2(cx - 9, cy - 10), Vector2(cx - 2, cy - 10), Color(0.2, 0.1, 0.05), 2.5)
	draw_line(Vector2(cx + 9, cy - 10), Vector2(cx + 2, cy - 10), Color(0.2, 0.1, 0.05), 2.5)
	draw_line(Vector2(cx - 4, cy + 4), Vector2(cx + 4, cy + 4), Color(0.2, 0.1, 0.05), 2.0)

# ===== 樱桃炸弹 =====
func _draw_cherrybomb_body() -> void:
	var sway = sin(anim_time * 6.0) * 4.0
	draw_line(Vector2(0, 20), Vector2(0, -15), Color(0.15, 0.45, 0.1), 4)
	draw_colored_polygon(
		PackedVector2Array([Vector2(1, -10), Vector2(-10, -16), Vector2(-2, -8)]),
		Color(0.2, 0.55, 0.15))
	draw_colored_polygon(
		PackedVector2Array([Vector2(1, -8), Vector2(10, -14), Vector2(0, -4)]),
		Color(0.18, 0.5, 0.12))
	draw_line(Vector2(0, -15), Vector2(-10, -28), Color(0.15, 0.45, 0.1), 2)
	draw_line(Vector2(0, -15), Vector2(10, -28), Color(0.15, 0.45, 0.1), 2)
	# 左樱桃
	draw_circle(Vector2(-11 + sway, -32), 16, Color(0.85, 0.08, 0.08))
	draw_circle(Vector2(-13 + sway, -34), 14, Color(0.95, 0.12, 0.12))
	draw_circle(Vector2(-15 + sway, -36), 5, Color(1.0, 0.3, 0.3, 0.5))
	# 右樱桃
	draw_circle(Vector2(11 - sway, -32), 16, Color(0.85, 0.08, 0.08))
	draw_circle(Vector2(9 - sway, -34), 14, Color(0.95, 0.12, 0.12))
	draw_circle(Vector2(7 - sway, -36), 5, Color(1.0, 0.3, 0.3, 0.5))
	# 愤怒眼睛
	draw_circle(Vector2(-14 + sway, -35), 5, Color.WHITE)
	draw_circle(Vector2(-15 + sway, -36), 2.5, Color.BLACK)
	draw_circle(Vector2(14 - sway, -35), 5, Color.WHITE)
	draw_circle(Vector2(15 - sway, -36), 2.5, Color.BLACK)
	# 愤怒眉毛
	draw_line(Vector2(-18 + sway, -41), Vector2(-10 + sway, -39), Color(0.1, 0, 0), 2.5)
	draw_line(Vector2(18 - sway, -41), Vector2(10 - sway, -39), Color(0.1, 0, 0), 2.5)
	# 愤怒嘴
	draw_arc(Vector2(-11 + sway, -30), 6, PI * 0.2, PI * 0.8, 5, Color(0.1, 0, 0), 2.0)
	draw_arc(Vector2(11 - sway, -30), 6, PI * 0.2, PI * 0.8, 5, Color(0.1, 0, 0), 2.0)
	# 导火索
	draw_line(Vector2(0, -18), Vector2(1, -38), Color(0.5, 0.4, 0.3), 1.5)
	var spark_angle = anim_time * 15.0
	var sx = 1 + cos(spark_angle) * 3
	var sy = -40 + sin(spark_angle) * 6
	draw_circle(Vector2(sx, sy), 3, Color(1.0, 0.8, 0.1, 0.9))
	draw_circle(Vector2(sx, sy), 1.5, Color.WHITE)

# ============== HP条 + 标签 ==============

func _draw_hp_bar() -> void:
	if max_health <= 0: return
	var ratio = clamp(health / max_health, 0.0, 1.0)
	var bar_w = 52.0
	var bar_y = 40
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w, 5), Color(0.1, 0.1, 0.1, 0.8))
	var hp_col = Color.GREEN if ratio > 0.5 else (Color.YELLOW if ratio > 0.25 else Color.RED)
	draw_rect(Rect2(-bar_w / 2, bar_y, bar_w * ratio, 5), hp_col)

func _draw_label() -> void:
	var font = ThemeDB.fallback_font
	if not font: return
	var fsize = 10
	draw_string(font, Vector2(-24, 36), tower_name, HORIZONTAL_ALIGNMENT_CENTER, 50, fsize)
