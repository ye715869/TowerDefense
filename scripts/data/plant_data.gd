# PlantData - 植物属性数据库（Autoload 单例）
extends Node

# 植物类型枚举
enum PlantType {
	SUNFLOWER,    # 向日葵 — 生产阳光
	PEASHOOTER,   # 豌豆射手 — 基础攻击
	SNOW_PEA,     # 冰冻射手 — 减速
	WALL_NUT,     # 坚果墙 — 肉盾
	CHERRY_BOMB,  # 樱桃炸弹 — 范围爆炸
}

# 植物属性字典
var plants = {
	PlantType.SUNFLOWER: {
		"name": "向日葵",
		"cost": 50,
		"health": 100,
		"damage": 0,
		"attack_speed": 0.0,      # 不攻击
		"range": 0,               # 不攻击
		"sun_production": 25,     # 每次生产阳光量
		"sun_interval": 10.0,     # 生产间隔（秒）
		"color": Color(1.0, 0.9, 0.2),   # 黄色
		"description": "生产阳光",
	},
	PlantType.PEASHOOTER: {
		"name": "豌豆射手",
		"cost": 100,
		"health": 100,
		"damage": 20,
		"attack_speed": 0.5,      # 攻击间隔（秒）
		"range": 9999,            # 直线无限射程
		"sun_production": 0,
		"sun_interval": 0.0,
		"color": Color(0.2, 0.8, 0.3),   # 绿色
		"description": "直线攻击",
		"projectile": "pea",
	},
	PlantType.SNOW_PEA: {
		"name": "冰冻射手",
		"cost": 175,
		"health": 100,
		"damage": 20,
		"attack_speed": 1.5,
		"range": 9999,
		"sun_production": 0,
		"sun_interval": 0.0,
		"color": Color(0.3, 0.7, 1.0),   # 冰蓝色
		"description": "减速敌人",
		"projectile": "ice",
		"slow_amount": 0.5,       # 减速50%
		"slow_duration": 2.0,     # 减速持续2秒
	},
	PlantType.WALL_NUT: {
		"name": "坚果墙",
		"cost": 50,
		"health": 400,
		"damage": 0,
		"attack_speed": 0.0,
		"range": 0,
		"sun_production": 0,
		"sun_interval": 0.0,
		"color": Color(0.7, 0.5, 0.3),   # 棕色
		"description": "阻挡敌人",
	},
	PlantType.CHERRY_BOMB: {
		"name": "樱桃炸弹",
		"cost": 150,
		"health": 1,
		"damage": 100,
		"attack_speed": 1.0,      # 引爆倒计时
		"range": 1,               # 3×3 范围（曼哈顿距离 ≤1）
		"sun_production": 0,
		"sun_interval": 0.0,
		"color": Color(1.0, 0.2, 0.2),   # 红色
		"description": "范围爆炸",
		"one_shot": true,         # 一次性使用
	},
}

# 获取植物属性
func get_plant(plant_type: PlantType) -> Dictionary:
	return plants.get(plant_type, {})

# 获取植物费用
func get_cost(plant_type: PlantType) -> int:
	return plants.get(plant_type, {}).get("cost", 0)
