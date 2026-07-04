# WaveManager - 敌人波次生成控制
extends Node

var current_level: int = 1
var level_data: Dictionary = {}
var spawn_queue: Array = []
var spawn_timer: float = 0.0
var current_group_index: int = 0
var current_group_remaining: int = 0
var current_group_type: int = -1
var current_group_interval: float = 0.0
var is_spawning: bool = false

@onready var game_manager: Node = null
@onready var enemies_container: Node = null

var enemy_scenes = {
	EnemyData.EnemyType.BASIC: "res://scenes/basic_zombie.tscn",
	EnemyData.EnemyType.CONE: "res://scenes/cone_zombie.tscn",
	EnemyData.EnemyType.RUNNER: "res://scenes/runner_zombie.tscn",
	EnemyData.EnemyType.GIANT: "res://scenes/giant_zombie.tscn",
}

func _ready() -> void:
	game_manager = get_parent()
	# 使用绝对路径确保找到节点
	enemies_container = get_node_or_null("/root/Main/Battlefield/Enemies")

func start_level(level_num: int) -> void:
	current_level = level_num
	level_data = WaveConfig.get_level(level_num)

func _process_next_group() -> void:
	if current_group_index >= spawn_queue.size():
		is_spawning = false
		return
	var group = spawn_queue[current_group_index]
	current_group_type = group.get("enemy_type", 0)
	current_group_remaining = group.get("count", 0)
	current_group_interval = group.get("spawn_interval", 5.0)
	spawn_timer = 0.0  # 立即生成第一个

func spawn_wave(wave_num: int) -> void:
	if level_data.is_empty(): return
	var waves = level_data.get("waves", [])
	if wave_num < 1 or wave_num > waves.size(): return
	var wave = waves[wave_num - 1]
	var groups = wave.get("groups", [])
	spawn_queue.clear()
	for g in groups:
		spawn_queue.append(g)
	is_spawning = true
	current_group_index = 0
	_process_next_group()

func _process(delta: float) -> void:
	if not is_spawning: return
	if not game_manager or game_manager.current_state != 1: return
	spawn_timer -= delta
	if spawn_timer <= 0 and current_group_remaining > 0:
		_spawn_enemy(current_group_type)
		current_group_remaining -= 1
		if current_group_remaining > 0:
			spawn_timer = current_group_interval
		else:
			current_group_index += 1
			if current_group_index < spawn_queue.size():
				var delay = spawn_queue[current_group_index].get("delay_before", 0.0)
				spawn_timer = current_group_interval + delay
				_process_next_group()
			else:
				is_spawning = false

func _spawn_enemy(enemy_type: int) -> void:
	var scene_path = enemy_scenes.get(enemy_type, "")
	if scene_path.is_empty(): return
	if not enemies_container:
		# 用绝对路径再试一次
		enemies_container = get_node_or_null("/root/Main/Battlefield/Enemies")
		if not enemies_container: return

	var enemy_scene = load(scene_path)
	if not enemy_scene: return

	var enemy = enemy_scene.instantiate()
	var row = randi() % 5
	enemy.setup(enemy_type, row)
	var spawn_x = 40.0 + 9 * 100 + 50
	var spawn_y = 80.0 + row * 100 + 50
	enemy.position = Vector2(spawn_x, spawn_y)
	enemies_container.add_child(enemy)
