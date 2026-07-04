# CherryBomb - 樱桃炸弹（对齐 Peashooter 模式）
class_name CherryBomb
extends Tower

func _process(delta: float) -> void:
	# 必须调用基类：anim_time、attack_timer 倒计时、queue_redraw
	super._process(delta)

func _attack() -> void:
	# 基类 attack_timer 到期时自动调用
	print("[CherryBomb] _attack() triggered, damage=", damage)
	_explode()

func _explode() -> void:
	print("[CherryBomb] EXPLODING row=", row, " col=", col, " damage=", damage)

	# 统计命中数
	var hit_count = 0

	# 伤害 3×3 范围内所有敌人（曼哈顿距离 ≤1）
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_alive:
			continue
		var dr = abs(enemy.row - row)
		var dc = abs(enemy.col - col)
		if dr <= 1 and dc <= 1:
			print("[CherryBomb]   HIT enemy at row=", enemy.row, " col=", enemy.col)
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
			hit_count += 1

	print("[CherryBomb] Total hits: ", hit_count)

	# 从 grid 清除
	if grid_ref and row >= 0 and col >= 0:
		grid_ref.remove_plant(row, col)

	# 爆炸视觉特效
	_spawn_explosion_effect()

	# 销毁自身
	queue_free()

func _spawn_explosion_effect() -> void:
	var p = get_parent()
	if not p:
		return

	# 三层扩散圆环
	for i in range(3):
		var sz = 40 + i * 35
		var ring = ColorRect.new()
		ring.color = Color(1.0, 0.3 + i * 0.3, 0.1, 0.7 - i * 0.2)
		ring.size = Vector2(sz, sz)
		ring.position = -ring.size / 2.0
		var t = Node2D.new()
		t.position = global_position
		t.scale = Vector2(0.1, 0.1)
		t.add_child(ring)
		p.add_child(t)
		var tw = t.create_tween()
		tw.tween_property(t, "scale", Vector2(2.0, 2.0), 0.3 + i * 0.2)
		tw.parallel().tween_property(ring, "color:a", 0.0, 0.3 + i * 0.2)
		tw.tween_callback(t.queue_free)

	# 16 个碎片
	for i in range(16):
		var frag = ColorRect.new()
		frag.color = Color(1.0, randf_range(0.2, 0.8), 0.05, 0.9)
		frag.size = Vector2(randf_range(4, 12), randf_range(4, 12))
		frag.position = -frag.size / 2.0
		var t = Node2D.new()
		t.position = global_position
		t.add_child(frag)
		p.add_child(t)
		var dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var tw = t.create_tween()
		tw.tween_property(t, "position", global_position + dir * randf_range(50, 120), randf_range(0.3, 0.6))
		tw.parallel().tween_property(frag, "modulate:a", 0.0, randf_range(0.3, 0.6))
		tw.tween_callback(t.queue_free)

func _draw() -> void:
	# 先画基类植物本体（花盆 + 脸 + HP 条 + 名字）
	super._draw()

	# 红色闪烁覆盖层
	var flash = abs(sin(attack_timer * 12.0))
	draw_circle(Vector2(0, -6), 22, Color(1.0, 0.15, 0.1, 0.4 + flash * 0.3))

	# 倒计时数字
	var font = ThemeDB.fallback_font
	if font:
		draw_string(font, Vector2(-8, 18), str(ceil(attack_timer)), HORIZONTAL_ALIGNMENT_CENTER, 16, 18)
