# Sunflower - 向日葵：生产阳光，不攻击
class_name Sunflower
extends Tower

# 向日葵只生产阳光，攻击逻辑在基类 _produce_sun() 中

func _attack() -> void:
	pass  # 向日葵不攻击，只生产阳光
