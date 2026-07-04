# WaveConfig - 波次配置数据库（Autoload 单例）
extends Node

# 波次数据结构：每波包含多组敌人
# groups: [{enemy_type, count, spawn_interval, delay_before}]

var levels = {
	1: {
		"name": "第一关",
		"initial_sun": 150,
		"waves": [
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.BASIC, "count": 3, "spawn_interval": 5.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.BASIC, "count": 5, "spawn_interval": 4.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.BASIC, "count": 3, "spawn_interval": 4.0 },
					{ "enemy_type": EnemyData.EnemyType.CONE, "count": 2, "spawn_interval": 6.0, "delay_before": 10.0 }
				]
			},
		],
	},
	2: {
		"name": "第二关",
		"initial_sun": 200,
		"waves": [
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.BASIC, "count": 5, "spawn_interval": 4.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.RUNNER, "count": 4, "spawn_interval": 3.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.CONE, "count": 4, "spawn_interval": 5.0 },
					{ "enemy_type": EnemyData.EnemyType.RUNNER, "count": 3, "spawn_interval": 3.0, "delay_before": 8.0 }
				]
			},
		],
	},
	3: {
		"name": "第三关",
		"initial_sun": 250,
		"waves": [
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.BASIC, "count": 5, "spawn_interval": 3.0 },
					{ "enemy_type": EnemyData.EnemyType.CONE, "count": 3, "spawn_interval": 5.0, "delay_before": 8.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.RUNNER, "count": 6, "spawn_interval": 2.5 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.CONE, "count": 5, "spawn_interval": 4.0 },
					{ "enemy_type": EnemyData.EnemyType.GIANT, "count": 1, "spawn_interval": 0.0, "delay_before": 12.0 }
				]
			},
			{
				"groups": [
					{ "enemy_type": EnemyData.EnemyType.GIANT, "count": 2, "spawn_interval": 8.0 },
					{ "enemy_type": EnemyData.EnemyType.RUNNER, "count": 5, "spawn_interval": 3.0, "delay_before": 6.0 }
				]
			},
		],
	},
}

# 获取关卡配置
func get_level(level_num: int) -> Dictionary:
	return levels.get(level_num, {})

# 获取关卡的波次数量
func get_wave_count(level_num: int) -> int:
	var level = levels.get(level_num, {})
	return level.get("waves", []).size()
