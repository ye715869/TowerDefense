# WallNut - 坚果墙：高血量肉盾，不攻击
class_name WallNut
extends Tower

# 坚果墙不攻击，只需要承受伤害
# 所有逻辑在基类 Tower 中处理（血量管理）

func _attack() -> void:
	pass  # 坚果墙不攻击
