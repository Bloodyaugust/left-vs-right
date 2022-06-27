extends Node2D

const UNIT_SCENE:PackedScene = preload("res://actors/Unit.tscn")
const MAX_UNITS:int = 1000
const SKELETON_DATA:Resource = preload("res://data/units/skeleton.tres")
const SPAWN_INTERVAL:float = 0.5

var units:Array = []

@onready var _spawn_points:Array = get_tree().get_nodes_in_group("spawners")

var _dead_units:Array = []
var _live_units:Array = []
var _time_to_spawn:float = 0.0

func _on_unit_died(unit:Node2D) -> void:
  _dead_units.append(unit)
  _live_units.erase(unit)

func _process(delta):
  _time_to_spawn = clampf(_time_to_spawn - delta, 0.0, SPAWN_INTERVAL)
  
  if _time_to_spawn <= 0.0:
    var _spawning_unit:Node2D = _dead_units.pop_front()
    
    _spawning_unit.initialize(SKELETON_DATA)
    _time_to_spawn = SPAWN_INTERVAL

func _warmup() -> void:
  for i in range(MAX_UNITS):
    var _new_unit:Node2D = UNIT_SCENE.instantiate()
    
    $"/root".add_child(_new_unit)
    units.append(_new_unit)
    _dead_units.append(_new_unit)
    _new_unit.died.connect(_on_unit_died)

func _ready():
  call_deferred("_warmup")
