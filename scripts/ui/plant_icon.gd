# PlantIcon - PvZ风格植物图标（程序化绘制）
class_name PlantIcon
extends Node2D

var plant_type: int = -1
var anim_time: float = 0.0

func setup(type: int) -> void:
	plant_type = type

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _draw() -> void:
	match plant_type:
		GameData.PlantType.SUNFLOWER:
			_draw_sunflower_icon()
		GameData.PlantType.PEASHOOTER:
			_draw_peashooter_icon()
		GameData.PlantType.SNOW_PEA:
			_draw_snowpea_icon()
		GameData.PlantType.WALL_NUT:
			_draw_wallnut_icon()
		GameData.PlantType.CHERRY_BOMB:
			_draw_cherrybomb_icon()
		_:
			_draw_generic_icon()

# ===== 向日葵 =====
func _draw_sunflower_icon() -> void:
	var t = anim_time
	for i in range(10):
		var a = TAU * i / 10.0 + t * 0.5
		draw_circle(Vector2(cos(a) * 12, sin(a) * 10 - 2), 5, Color(1, 0.85, 0.1) if i % 2 == 0 else Color(1, 0.7, 0.05))
	draw_circle(Vector2(0, -2), 8, Color(0.45, 0.25, 0.1))
	draw_circle(Vector2(0, -2), 6, Color(0.5, 0.3, 0.12))
	draw_circle(Vector2(-3, -5), 2, Color.WHITE); draw_circle(Vector2(3, -5), 2, Color.WHITE)
	draw_circle(Vector2(-2, -4.5), 1, Color.BLACK); draw_circle(Vector2(4, -4.5), 1, Color.BLACK)
	draw_arc(Vector2(0, -1.5), 3, PI * 0.1, PI * 0.9, 4, Color(0.1, 0.1, 0.1), 1)
	draw_line(Vector2(0, 8), Vector2(0, 18), Color(0.15, 0.5, 0.1), 3)

# ===== 豌豆射手 =====
func _draw_peashooter_icon() -> void:
	draw_line(Vector2(0, 10), Vector2(0, 18), Color(0.15, 0.5, 0.1), 3)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-2, -6), Vector2(-10, -2), Vector2(0, 4)]),
		Color(0.2, 0.55, 0.12))
	draw_circle(Vector2(0, 0), 13, Color(0.18, 0.7, 0.2))
	draw_circle(Vector2(-1, -1), 11, Color(0.22, 0.75, 0.25))
	var be = 16
	draw_colored_polygon(
		PackedVector2Array([Vector2(6, -5), Vector2(be, -5), Vector2(be, 2), Vector2(6, 5)]),
		Color(0.18, 0.65, 0.18))
	draw_rect(Rect2(be - 1, -7, 3, 9), Color(0.15, 0.55, 0.12))
	draw_circle(Vector2(0, -7), 6, Color.WHITE)
	draw_circle(Vector2(2, -7), 3, Color.BLACK)
	draw_circle(Vector2(3, -8), 1, Color.WHITE)

# ===== 冰冻射手 =====
func _draw_snowpea_icon() -> void:
	var t = anim_time
	draw_line(Vector2(0, 10), Vector2(0, 18), Color(0.1, 0.4, 0.25), 3)
	draw_colored_polygon(
		PackedVector2Array([Vector2(-2, -6), Vector2(-10, -2), Vector2(0, 4)]),
		Color(0.15, 0.5, 0.4))
	draw_circle(Vector2(0, 0), 13, Color(0.2, 0.55, 0.85))
	draw_circle(Vector2(-1, -1), 11, Color(0.3, 0.65, 0.9))
	for i in range(3):
		draw_circle(Vector2(cos(t * 4 + i * 2.1) * 10, sin(t * 3 + i * 2.1) * 8), 2, Color(0.8, 0.95, 1, 0.6))
	var be = 16
	draw_colored_polygon(
		PackedVector2Array([Vector2(6, -5), Vector2(be, -5), Vector2(be, 2), Vector2(6, 5)]),
		Color(0.18, 0.5, 0.8))
	draw_rect(Rect2(be - 1, -7, 3, 9), Color(0.12, 0.4, 0.7))
	draw_circle(Vector2(0, -7), 6, Color.WHITE)
	draw_circle(Vector2(2, -7), 3, Color(0.1, 0.2, 0.5))
	draw_circle(Vector2(3, -8), 1, Color.WHITE)

# ===== 坚果墙 =====
func _draw_wallnut_icon() -> void:
	draw_circle(Vector2(0, 0), 18, Color(0.55, 0.35, 0.15))
	draw_circle(Vector2(-1, -2), 16, Color(0.65, 0.42, 0.2))
	draw_line(Vector2(-5, -15), Vector2(-3, -6), Color(0.4, 0.25, 0.1), 1.2)
	draw_line(Vector2(6, -10), Vector2(3, -1), Color(0.4, 0.25, 0.1), 1.2)
	draw_arc(Vector2(0, -14), 5, PI * 0.8, PI * 1.5, 4, Color(0.35, 0.2, 0.08), 0.8)
	draw_circle(Vector2(-5, -4), 3, Color.WHITE); draw_circle(Vector2(5, -4), 3, Color.WHITE)
	draw_circle(Vector2(-4, -3.5), 2, Color.BLACK); draw_circle(Vector2(6, -3.5), 2, Color.BLACK)
	draw_line(Vector2(-7, -8), Vector2(-1, -8), Color(0.2, 0.1, 0.05), 2)
	draw_line(Vector2(7, -8), Vector2(1, -8), Color(0.2, 0.1, 0.05), 2)
	draw_line(Vector2(-3, 3), Vector2(3, 3), Color(0.2, 0.1, 0.05), 1.5)

# ===== 樱桃炸弹 =====
func _draw_cherrybomb_icon() -> void:
	var t = anim_time
	var s = sin(t * 8) * 2
	draw_line(Vector2(0, 10), Vector2(0, 0), Color(0.15, 0.45, 0.1), 2)
	draw_line(Vector2(0, 0), Vector2(-6, -10), Color(0.15, 0.45, 0.1), 1.5)
	draw_line(Vector2(0, 0), Vector2(6, -10), Color(0.15, 0.45, 0.1), 1.5)
	draw_circle(Vector2(-7 + s, -14), 11, Color(0.85, 0.08, 0.08))
	draw_circle(Vector2(-8 + s, -15), 9, Color(0.95, 0.12, 0.12))
	draw_circle(Vector2(7 - s, -14), 11, Color(0.85, 0.08, 0.08))
	draw_circle(Vector2(6 - s, -15), 9, Color(0.95, 0.12, 0.12))
	draw_circle(Vector2(-10 + s, -16), 3, Color(1, 0.3, 0.3, 0.5))
	draw_circle(Vector2(4 - s, -16), 3, Color(1, 0.3, 0.3, 0.5))
	draw_circle(Vector2(-9 + s, -16), 3, Color.WHITE); draw_circle(Vector2(9 - s, -16), 3, Color.WHITE)
	draw_circle(Vector2(-9.5 + s, -16.5), 1.5, Color.BLACK); draw_circle(Vector2(9.5 - s, -16.5), 1.5, Color.BLACK)
	draw_line(Vector2(-12 + s, -20), Vector2(-6 + s, -18), Color(0.1, 0, 0), 1.5)
	draw_line(Vector2(12 - s, -20), Vector2(6 - s, -18), Color(0.1, 0, 0), 1.5)
	var sx = cos(t * 12) * 2
	var sy = -22 - abs(sin(t * 12)) * 3
	draw_circle(Vector2(sx, sy), 2, Color(1, 0.8, 0.1, 0.9))

# ===== 通用降级 =====
func _draw_generic_icon() -> void:
	draw_circle(Vector2.ZERO, 16, Color(0.5, 0.5, 0.5))
	draw_circle(Vector2(-4, -2), 3, Color.BLACK)
	draw_circle(Vector2(4, -2), 3, Color.BLACK)
