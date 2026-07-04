# CherryBomb - 樱桃炸弹（爆炸特效增强版）
class_name CherryBomb
extends Tower

var explode_timer: float = 1.0
var has_exploded: bool = false

func _process(delta: float) -> void:
	if not is_alive or has_exploded: return
	explode_timer -= delta
	if explode_timer <= 0: _explode()
	queue_redraw()

func _attack() -> void: pass

func _explode() -> void:
	has_exploded = true
	_spawn_explosion_effect()
	if grid_ref:
		var enemies = grid_ref.get_enemies_in_range(row, col, 1)
		for enemy in enemies:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
		grid_ref.remove_plant(row, col)
	queue_free()

func _spawn_explosion_effect() -> void:
	# 多层爆炸环
	var rings_data = [
		{"size": 40, "color": Color(1.0, 0.2, 0.1), "dur": 0.4},
		{"size": 70, "color": Color(1.0, 0.5, 0.1), "dur": 0.55},
		{"size": 100, "color": Color(0.9, 0.7, 0.1), "dur": 0.7},
	]
	for ri in rings_data:
		var ring = ColorRect.new()
		ring.color = ri.color
		ring.color.a = 0.6
		ring.size = Vector2(ri.size, ri.size)
		ring.position = -ring.size / 2
		var t = Node2D.new()
		t.position = global_position
		t.scale = Vector2(0.2, 0.2)
		t.add_child(ring)
		get_parent().add_child(t)
		var tw = t.create_tween()
		tw.tween_property(t, "scale", Vector2(1.8, 1.8), ri.dur)
		tw.parallel().tween_property(ring, "color:a", 0.0, ri.dur)
		tw.tween_callback(t.queue_free)

	# 碎片粒子
	for i in range(25):
		var frag = ColorRect.new()
		frag.color = Color(1.0, randf_range(0.3, 0.8), 0.1, 0.9)
		frag.size = Vector2(randf_range(3, 10), randf_range(3, 10))
		frag.position = Vector2(-frag.size.x / 2, -frag.size.y / 2)
		var t = Node2D.new()
		t.position = global_position
		t.add_child(frag)
		get_parent().add_child(t)
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var tw = t.create_tween()
		tw.tween_property(t, "position", global_position + dir * randf_range(60, 130), randf_range(0.3, 0.7))
		tw.parallel().tween_property(frag, "modulate:a", 0.0, randf_range(0.3, 0.6))
		tw.tween_callback(t.queue_free)

func _draw() -> void:
	var data = GameData.get_plant(plant_type)
	var col = data.get("color", Color.RED)
	var flash = sin(explode_timer * 15.0) * 0.5 + 0.5
	var r = col.r; var g = col.g * flash; var b = col.b * flash
	# 花盆
	draw_circle(Vector2.ZERO, 26, Color(0.45, 0.28, 0.15))
	# 闪烁头部
	draw_circle(Vector2(0, -5), 22, Color(r, g, b))
	# 眼睛
	draw_circle(Vector2(-7, -10), 5, Color.WHITE)
	draw_circle(Vector2(5, -10), 5, Color.WHITE)
	draw_circle(Vector2(-6, -9), 2.5, Color.BLACK)
	draw_circle(Vector2(6, -9), 2.5, Color.BLACK)
	# 危险标记
	var font = ThemeDB.fallback_font
	if font:
		draw_string(font, Vector2(-10, 12), "!!!", HORIZONTAL_ALIGNMENT_CENTER, 28, 14, 2)
