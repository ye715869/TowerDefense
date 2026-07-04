# EnemyData - 敌人属性数据库（Autoload 单例）
extends Node

# 敌人类型枚举
enum EnemyType {
	BASIC,     # 普通敌人
	CONE,      # 头盔敌人
	RUNNER,    # 跑步敌人
	GIANT,     # 大型敌人
}

var enemies = {
	EnemyType.BASIC: {
		"name": "普通敌人",
		"health": 100,
		"speed": 20.0,            # 像素/秒
		"damage": 20.0,           # 到达底线时每秒伤害
		"color": Color(0.6, 0.6, 0.6),
		"reward": 25,             # 击杀奖励阳光
	},
	EnemyType.CONE: {
		"name": "头盔敌人",
		"health": 200,
		"speed": 20.0,
		"damage": 20.0,
		"color": Color(0.8, 0.5, 0.2),
		"reward": 35,
	},
	EnemyType.RUNNER: {
		"name": "跑步敌人",
		"health": 100,
		"speed": 35.0,
		"damage": 20.0,
		"color": Color(0.3, 0.8, 0.4),
		"reward": 25,
	},
	EnemyType.GIANT: {
		"name": "大型敌人",
		"health": 500,
		"speed": 10.0,
		"damage": 40.0,
		"color": Color(0.8, 0.2, 0.2),
		"reward": 75,
	},
}

func get_enemy(enemy_type: EnemyType) -> Dictionary:
	return enemies.get(enemy_type, {})
