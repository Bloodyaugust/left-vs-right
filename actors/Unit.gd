extends RigidDynamicBody2D

signal died(unit)

@export var data:Resource
@export var team:int

var alive:bool = true

@onready var _heros:Array = get_tree().get_nodes_in_group("heros")
@onready var _sprite:Sprite2D = $"Sprite2D"

var _attack_cooldown:float
var _health:float
var _touching_target:bool
var _target:Node2D

func damage(amount:float) -> void:
  _health = clampf(_health - (amount - data.armor), 0.0, data.health)
  
  if _health <= 0:
    died.emit(self)
    reset()

func initialize(new_data:Resource) -> void:
  data = new_data
  alive = true
  _health = data.health
  _find_target()
  _sprite.visible = true
  process_mode = Node.PROCESS_MODE_INHERIT

func reset() -> void:
  process_mode = Node.PROCESS_MODE_DISABLED
  alive = false
  _attack_cooldown = 0.0
  _touching_target = false
  _target = null
  _sprite.visible = false

func _attack(target:Node2D) -> void:
  target.damage(data.damage)
  _attack_cooldown = data.attack_interval

func _body_entered(body:Node) -> void:
  if body == _target:
    _touching_target = true

func _body_exited(body:Node) -> void:
  if body == _target:
    _touching_target = false

func _integrate_forces(state:PhysicsDirectBodyState2D):
  if alive && _target != null:
    var _direction_vector:Vector2 = global_position.direction_to(_target.global_position)
    state.linear_velocity = _direction_vector * data.speed
  else:
    state.linear_velocity = Vector2.ZERO

func _process(delta):
  if alive:
    _attack_cooldown = clampf(_attack_cooldown - delta, 0.0, data.attack_interval)

    if _attack_cooldown <= 0.0 && _target != null && _touching_target:
      _attack(_target)

func _ready():
  body_entered.connect(_body_entered)
  body_exited.connect(_body_exited)
  $"Sprite2D".texture = data.sprite

  _heros = _heros.filter(func(hero): return hero.team != team)
  reset()

func _target_died(hero) -> void:
  _target.died.disconnect(_target_died)
  _target = null
  _find_target()

func _find_target() -> void:
  var _alive_enemy_heros:Array = _heros.filter(func(hero): return hero.alive)

  if len(_alive_enemy_heros) > 0 && GDUtil.reference_safe(_alive_enemy_heros[0]):
    _target = _alive_enemy_heros[0]
    _target.died.connect(_target_died)
