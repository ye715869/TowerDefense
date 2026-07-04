# Projectile - 子弹/投射物（美化版）
class_name Projectile
extends Area2D

var speed: float = 300.0
var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var slow_amount: float = 0.0
var slow_duration: float = 0.0
var anim_time: float = 0.0

func _ready() -> void:
	add_to_group("projectiles")

func setup(dmg: float, spd: float, dir: Vector2, slow_amt: float = 0.0, slow_dur: float = 0.0) -> void:
	damage = dmg; speed = spd; direction = dir
	slow_amount = slow_amt; slow_duration = slow_dur

func _process(delta: float) -> void:
	anim_time += delta
	position += direction * speed * delta
	if position.x > 1200 or position.x < -100:
		queue_free()
		return
	# 手动碰撞检测 — Enemy 是 Node2D 非物理体，body_entered 不会触发
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.has_method("take_damage"): continue
		if not enemy.is_alive: continue
		if enemy.global_position.distance_to(global_position) < 30:
			enemy.take_damage(damage)
			if slow_amount > 0: enemy.apply_slow(slow_amount, slow_duration)
			_spawn_hit_spark(enemy.global_position)
			queue_free()
			return
	queue_redraw()

func _spawn_hit_spark(hit_pos: Vector2) -> void:
	for i in range(4):
		var spark = ColorRect.new()
		spark.color = Color(1, 0.8, 0.2) if slow_amount == 0 else Color(0.3, 0.7, 1)
		spark.size = Vector2(4, 4)
		spark.position = Vector2(-2, -2)
		var t = Node2D.new()
		t.position = hit_pos
		t.add_child(spark)
		get_parent().add_child(t)
		var tw = t.create_tween()
		tw.tween_property(t, "position", hit_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15)), 0.25)
		tw.parallel().tween_property(spark, "modulate:a", 0.0, 0.25)
		tw.tween_callback(t.queue_free)

func _draw() -> void:
	var is_ice = slow_amount > 0
	var color = Color(0.3, 0.7, 1.0) if is_ice else Color(0.3, 1.0, 0.3)
	# 子弹主体（椭圆）
	draw_circle(Vector2.ZERO, 5, color)
	draw_circle(Vector2(-3, 0), 3, color.lightened(0.5))
	# 拖尾
	var trail_col = color.darkened(0.3)
	trail_col.a = 0.3
	for i in range(3):
		var tx = -8.0 - i * 5.0
		draw_circle(Vector2(tx, 0), 4.0 - i, trail_col)
