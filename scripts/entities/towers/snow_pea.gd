# SnowPea - 冰冻射手：直线攻击，蓝色子弹附带减速
class_name SnowPea
extends Tower

func _attack() -> void:
	if not is_alive or not grid_ref:
		return

	var enemies = grid_ref.get_enemies_in_row(row)
	if enemies.is_empty():
		return

	for enemy in enemies:
		if enemy.global_position.x > global_position.x:
			_fire_projectile(enemy)
			return

func _fire_projectile(_target: Node2D) -> void:
	var proj_scene = load("res://scenes/projectile.tscn")
	if not proj_scene:
		return

	var proj = proj_scene.instantiate()
	proj.position = global_position + Vector2(30, 0)
	proj.setup(damage, 300.0, Vector2.RIGHT, slow_amount, slow_duration)
	get_parent().add_child(proj)
