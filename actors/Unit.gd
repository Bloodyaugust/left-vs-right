extends RigidDynamicBody2D

@export var data:Resource
@export var team:int

@onready var _heros:Array = get_tree().get_nodes_in_group("heros")

var _attack_cooldown:float
var _health:float
var _target:Node2D

func damage(amount:float) -> void:
  _health -= amount

func _attack(target:Node2D) -> void:
  target.damage(data.damage)
  _attack_cooldown = data.attack_interval

func _body_entered(body:Node) -> void:
  print("body entered")
  if body.is_in_group("heros"):
    _target = body
    print("body is now target")

func _body_exited(body:Node) -> void:
  if body == _target:
    _target = null

func _integrate_forces(state:PhysicsDirectBodyState2D):
  if _health >= 0:
    var _direction_vector:Vector2 = global_position.direction_to(_heros[0].global_position)
    state.linear_velocity = _direction_vector * data.speed
    
    state.integrate_forces()

func _process(delta):
  if _health <= 0:
    queue_free()
  else:
    _attack_cooldown = clampf(_attack_cooldown - delta, 0.0, data.attack_interval)
    
    if !GDUtil.reference_safe(_target):
      _target = null
    
    if _attack_cooldown <= 0.0 && _target != null:
      _attack(_target)
      

func _ready():
  body_entered.connect(_body_entered)
  
  $"Sprite2D".texture = data.sprite
  _health = data.health
  
  _heros = _heros.filter(func(hero): return hero.team != team)
