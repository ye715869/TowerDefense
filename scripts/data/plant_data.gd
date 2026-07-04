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
		"attack_speed": 0.0,
		"range": 0,
		"sun_production": 25,
		"sun_interval": 6.0,
		"cooldown": 7.5,
		"color": Color(1.0, 0.9, 0.2),
		"description": "生产阳光",
	},
	PlantType.PEASHOOTER: {
		"name": "豌豆射手",
		"cost": 100,
		"health": 100,
		"damage": 40,
		"attack_speed": 1.5,
		"range": 9999,
		"sun_production": 0,
		"sun_interval": 0.0,
		"cooldown": 5.0,
		"color": Color(0.2, 0.8, 0.3),
		"description": "直线攻击",
		"projectile": "pea",
	},
	PlantType.SNOW_PEA: {
		"name": "冰冻射手",
		"cost": 175,
		"health": 100,
		"damage": 30,
		"attack_speed": 1.8,
		"range": 9999,
		"sun_production": 0,
		"sun_interval": 0.0,
		"cooldown": 7.5,
		"color": Color(0.3, 0.7, 1.0),
		"description": "减速敌人",
		"projectile": "ice",
		"slow_amount": 0.5,
		"slow_duration": 2.0,
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
		"cooldown": 20.0,
		"color": Color(0.7, 0.5, 0.3),
		"description": "阻挡敌人",
	},
	PlantType.CHERRY_BOMB: {
		"name": "樱桃炸弹",
		"cost": 150,
		"health": 9999,
		"damage": 300,           # 秒杀普通(100)/路障(200)/跑步(100)，巨人(500)剩200
		"attack_speed": 1.0,
		"range": 1,
		"sun_production": 0,
		"sun_interval": 0.0,
		"cooldown": 35.0,
		"color": Color(1.0, 0.2, 0.2),
		"description": "范围爆炸",
		"one_shot": true,
	},
}

func get_plant(plant_type: PlantType) -> Dictionary:
	return plants.get(plant_type, {})

func get_cost(plant_type: PlantType) -> int:
	return plants.get(plant_type, {}).get("cost", 0)

func get_cooldown(plant_type: PlantType) -> float:
	return plants.get(plant_type, {}).get("cooldown", 0.0)
