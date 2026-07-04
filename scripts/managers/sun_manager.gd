# SunManager - 阳光掉落/收集管理
extends Node

var sky_fall_timer: float = 0.0
var sky_fall_interval: float = 10.0  # 每10秒掉一个

@onready var game_manager: Node = null

func _ready() -> void:
	game_manager = get_parent()
	sky_fall_timer = sky_fall_interval

func _process(delta: float) -> void:
	if not game_manager or game_manager.current_state != 1:
		return

	sky_fall_timer -= delta
	if sky_fall_timer <= 0:
		_spawn_sky_sun()
		sky_fall_timer = sky_fall_interval

# 天降阳光
func _spawn_sky_sun() -> void:
	var sun_scene = load("res://scenes/sun.tscn")
	if not sun_scene:
		return

	var sun_instance = sun_scene.instantiate()
	# 随机 x 位置（战场范围内）
	var grid = get_node_or_null("../Battlefield/Grid")
	var x_min = 40.0
	var x_max = 40.0 + 9 * 100  # 9列 × 100px
	var x = randf_range(x_min + 50, x_max - 50)
	var y = randf_range(30, 200)  # 天上掉落
	sun_instance.position = Vector2(x, y)
	sun_instance.amount = 25
	add_child(sun_instance)

# 植物生产阳光（由 Tower 调用）
func add_sun(amount: int, source_position: Vector2) -> void:
	var sun_scene = load("res://scenes/sun.tscn")
	if not sun_scene:
		return

	var sun_instance = sun_scene.instantiate()
	sun_instance.position = source_position + Vector2(randf_range(-20, 20), -30)
	sun_instance.amount = amount
	add_child(sun_instance)
