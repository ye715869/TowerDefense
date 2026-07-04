# WaveManager - 双轨刷怪系统：动态常态化刷新 + 波次缩放
extends Node

# 双轨刷怪状态
enum SpawnState { IDLE, NORMAL, WAVE, FINAL_WAVE, ALL_DONE }

var spawn_state: int = SpawnState.IDLE
var wave_num: int = 0
const TOTAL_WAVES: int = 3

# 常态化刷新（动态参数，随波数变化）
var normal_timer: float = 0.0
var normal_interval: float = 10.0        # 当前刷新间隔（秒）
var normal_interval_cap: float = 5.0     # 速率上限 = 5.0 / (wave_num + 1)
var normal_spawn_speedup: float = 0.0    # 每刷一只减少的间隔
var normal_spawned_count: int = 0        # 本阶段已刷数量
var normal_trigger_count: int = 15       # 触发下波的阈值 = 15 * (wave_num + 1)

# 波次刷新
var wave_timer: float = 0.0
var wave_spawn_interval: float = 0.35    # 波次内每只间隔（秒）
var wave_remaining: int = 0
var wave_spawn_total: int = 0            # 本波刷怪总数 = 15 * wave_num
var wave_spawned: int = 0

# 波次通知
var notification_timer: float = 0.0
var show_notification: bool = false
const NOTIFICATION_DURATION: float = 2.5

# 胜利检测
var victory_delay_timer: float = 0.0
var waiting_for_victory: bool = false

# 引用
@onready var game_manager: Node = null
@onready var enemies_container: Node = null

var enemy_scenes = {
	EnemyData.EnemyType.BASIC: "res://scenes/basic_zombie.tscn",
	EnemyData.EnemyType.CONE: "res://scenes/cone_zombie.tscn",
	EnemyData.EnemyType.RUNNER: "res://scenes/runner_zombie.tscn",
	EnemyData.EnemyType.GIANT: "res://scenes/giant_zombie.tscn",
}

signal wave_notification(text: String)
signal wave_changed(current: int, total: int)
signal all_enemies_cleared()

func _ready() -> void:
	game_manager = get_parent()
	enemies_container = get_node_or_null("/root/Main/Battlefield/Enemies")

func start_level(_level_num: int) -> void:
	wave_num = 0
	normal_spawned_count = 0
	wave_spawned = 0
	wave_remaining = 0
	wave_spawn_total = 0
	waiting_for_victory = false
	victory_delay_timer = 0.0
	show_notification = false
	notification_timer = 0.0
	# 重置常态化间隔到初始值
	normal_interval = 10.0
	_start_normal_spawning()

func _start_normal_spawning() -> void:
	spawn_state = SpawnState.NORMAL
	normal_spawned_count = 0
	normal_timer = 1.0  # 1秒后开始第一只

	# 动态参数：基于下一波编号 (1, 2, 3)
	var upcoming = wave_num + 1

	# 速率上限：每5秒刷 upcoming 只 → 最小间隔 = 5.0 / upcoming
	normal_interval_cap = 5.0 / upcoming

	# 触发阈值：15 × upcoming
	normal_trigger_count = 15 * upcoming

	# 计算每只加速量：使间隔在达到触发阈值时正好到达速率上限
	if normal_interval > normal_interval_cap and normal_trigger_count > 0:
		normal_spawn_speedup = (normal_interval - normal_interval_cap) / float(normal_trigger_count)
	else:
		# 已在或低于上限，保持当前速度
		normal_interval = normal_interval_cap
		normal_spawn_speedup = 0.0

func _start_wave_spawning() -> void:
	spawn_state = SpawnState.WAVE
	wave_spawned = 0
	wave_spawn_total = 15 * wave_num       # 15 × 当前波数
	wave_remaining = wave_spawn_total
	wave_timer = 0.3  # 短延迟后开始
	wave_spawn_interval = 0.35

	# 显示通知
	show_notification = true
	notification_timer = NOTIFICATION_DURATION
	wave_notification.emit("⚠ 一大波僵尸正在逼近！")
	wave_changed.emit(wave_num, TOTAL_WAVES)

func _start_final_wave() -> void:
	spawn_state = SpawnState.FINAL_WAVE
	wave_spawned = 0
	wave_spawn_total = 15 * TOTAL_WAVES    # 最终波：15 × 3 = 45 只
	wave_remaining = wave_spawn_total
	wave_timer = 0.3
	wave_spawn_interval = 0.35

	show_notification = true
	notification_timer = NOTIFICATION_DURATION
	wave_notification.emit("☠ 最终波次！一大波僵尸正在逼近！")
	wave_changed.emit(wave_num, TOTAL_WAVES)

func _process(delta: float) -> void:
	if not game_manager or game_manager.current_state != 1:  # PLAYING
		return

	# 通知计时
	if show_notification:
		notification_timer -= delta
		if notification_timer <= 0:
			show_notification = false

	# 胜利等待计时
	if waiting_for_victory:
		victory_delay_timer -= delta
		if victory_delay_timer <= 0:
			waiting_for_victory = false
			all_enemies_cleared.emit()
		return

	# 常态化刷新
	if spawn_state == SpawnState.NORMAL:
		normal_timer -= delta
		if normal_timer <= 0:
			_spawn_random_enemy()
			normal_spawned_count += 1

			# 每刷一只加速（减少间隔）
			normal_interval -= normal_spawn_speedup
			if normal_interval < normal_interval_cap:
				normal_interval = normal_interval_cap

			# 到达触发数量 → 启动波次
			if normal_spawned_count >= normal_trigger_count:
				wave_num += 1
				if wave_num >= TOTAL_WAVES:
					_start_final_wave()
				else:
					_start_wave_spawning()
			else:
				normal_timer = normal_interval

	# 波次刷新
	elif spawn_state == SpawnState.WAVE or spawn_state == SpawnState.FINAL_WAVE:
		wave_timer -= delta
		if wave_timer <= 0 and wave_remaining > 0:
			_spawn_wave_enemy()
			wave_remaining -= 1
			wave_spawned += 1
			if wave_remaining > 0:
				wave_timer = wave_spawn_interval
			else:
				# 波次刷完
				if spawn_state == SpawnState.FINAL_WAVE:
					# 最终波次刷完，等待场上清空
					spawn_state = SpawnState.ALL_DONE
					_check_all_clear()
				else:
					# 普通波次结束，恢复常态化
					wave_notification.emit("波次 " + str(wave_num) + " 结束！")
					notification_timer = 1.5
					show_notification = true
					# 继续使用当前加速后的间隔，不重置
					_start_normal_spawning()

	# 检测胜利条件（最终波完成后）
	if spawn_state == SpawnState.ALL_DONE:
		_check_all_clear()

func _spawn_random_enemy() -> void:
	# 常态化僵尸：70%普通，20%路障，8%跑步，2%巨人
	var r = randf()
	var etype
	if r < 0.70:
		etype = EnemyData.EnemyType.BASIC
	elif r < 0.90:
		etype = EnemyData.EnemyType.CONE
	elif r < 0.98:
		etype = EnemyData.EnemyType.RUNNER
	else:
		etype = EnemyData.EnemyType.GIANT
	_spawn_enemy_at(etype, randi() % 5)

func _spawn_wave_enemy() -> void:
	# 波次僵尸：40%普通，30%路障，20%跑步，10%巨人
	var r = randf()
	var etype
	if r < 0.40:
		etype = EnemyData.EnemyType.BASIC
	elif r < 0.70:
		etype = EnemyData.EnemyType.CONE
	elif r < 0.90:
		etype = EnemyData.EnemyType.RUNNER
	else:
		etype = EnemyData.EnemyType.GIANT
	_spawn_enemy_at(etype, randi() % 5)

func _spawn_enemy_at(enemy_type: int, spawn_row: int) -> void:
	var scene_path = enemy_scenes.get(enemy_type, "")
	if scene_path.is_empty(): return
	if not enemies_container:
		enemies_container = get_node_or_null("/root/Main/Battlefield/Enemies")
		if not enemies_container: return

	var scene = load(scene_path)
	if not scene: return

	var enemy = scene.instantiate()
	enemy.setup(enemy_type, spawn_row)
	# 在战场右侧外生成
	var spawn_x = 40.0 + 9 * 100 + randf_range(30, 120)
	var spawn_y = 80.0 + spawn_row * 100 + 50
	enemy.position = Vector2(spawn_x, spawn_y)
	enemies_container.add_child(enemy)

func _check_all_clear() -> void:
	# 检查场上是否还有存活的僵尸
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e.is_alive:
			return

	# 全部清空
	if not waiting_for_victory:
		waiting_for_victory = true
		victory_delay_timer = 2.0
		wave_notification.emit("🎉 所有僵尸已被消灭！")

func get_wave_info() -> Dictionary:
	return {
		"wave_num": wave_num,
		"total_waves": TOTAL_WAVES,
		"state": spawn_state,
		"normal_count": normal_spawned_count,
		"normal_trigger": normal_trigger_count,
		"normal_interval": normal_interval,
		"wave_remaining": wave_remaining,
		"wave_total": wave_spawn_total,
	}

func force_wave() -> void:
	"""玩家手动跳波：立即触发波次刷新，波数+1"""
	if spawn_state != SpawnState.NORMAL:
		return  # 波次进行中不能跳

	wave_num += 1
	if wave_num >= TOTAL_WAVES:
		_start_final_wave()
	else:
		_start_wave_spawning()

func is_notification_active() -> bool:
	return show_notification
