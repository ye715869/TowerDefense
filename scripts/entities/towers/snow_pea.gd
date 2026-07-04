# SnowPea - 冰冻射手（视觉增强版）
class_name SnowPea
extends Tower

var muzzle_flash: float = 0.0

func _process(delta: float) -> void:
	super._process(delta)
	if muzzle_flash > 0: muzzle_flash -= delta

func _attack() -> void:
	if not is_alive or not grid_ref: return
	var enemies = grid_ref.get_enemies_in_row(row)
	if enemies.is_empty(): return
	for enemy in enemies:
		if enemy.global_position.x > global_position.x:
			_fire_projectile(enemy)
			return

func _fire_projectile(_target: Node2D) -> void:
	var proj_scene = load("res://scenes/projectile.tscn")
	if not proj_scene: return
	var proj = proj_scene.instantiate()
	proj.position = global_position + Vector2(30, 0)
	proj.setup(damage, 300.0, Vector2.RIGHT, slow_amount, slow_duration)
	get_parent().add_child(proj)
	muzzle_flash = 0.1

func _draw() -> void:
	super._draw()
	if muzzle_flash > 0:
		draw_circle(Vector2(28, -5), 8.0, Color(0.4, 0.8, 1.0, muzzle_flash * 5))
		draw_circle(Vector2(28, -5), 4.0, Color.WHITE * muzzle_flash * 5)
