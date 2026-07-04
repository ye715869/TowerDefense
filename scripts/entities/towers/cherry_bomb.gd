# CherryBomb - 樱桃炸弹：放置后倒计时，然后 3×3 范围爆炸
class_name CherryBomb
extends Tower

var explode_timer: float = 0.0
var has_exploded: bool = false

func _ready() -> void:
	super._ready()
	explode_timer = 1.0  # 1秒后爆炸

func _process(delta: float) -> void:
	if not is_alive or has_exploded:
		return

	# 闪烁效果（越接近爆炸越快）
	explode_timer -= delta
	if body:
		var flash = sin(explode_timer * 20.0) * 0.5 + 0.5
		body.modulate = Color(1.0, flash, flash)

	if explode_timer <= 0:
		_explode()

func _attack() -> void:
	pass  # 樱桃炸弹使用特殊的爆炸逻辑

func _explode() -> void:
	has_exploded = true
	if not grid_ref:
		queue_free()
		return

	# 获取范围内的敌人
	var enemies = grid_ref.get_enemies_in_range(row, col, 1)  # 3×3范围
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

	# 从网格中移除自己
	grid_ref.remove_plant(row, col)
	queue_free()
