# Peashooter - 豌豆射手：直线攻击，发射绿色子弹
class_name Peashooter
extends Tower

func _attack() -> void:
	if not is_alive or not grid_ref:
		return

	# 找到同行右侧的第一个敌人
	var enemies = grid_ref.get_enemies_in_row(row)
	if enemies.is_empty():
		return

	# 检查敌人在右侧
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
	proj.setup(damage, 300.0, Vector2.RIGHT)
	get_parent().add_child(proj)
