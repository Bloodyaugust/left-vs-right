extends RigidDynamicBody2D

signal died(hero)

@export var data:Resource
@export var team:int

var alive:bool = true

var _health:float = 0
var _move_direction:Vector2 = Vector2.ZERO

func damage(amount:float) -> void:
  _health = clampf(_health - (amount - data.armor), 0.0, data.health)
  
  if _health <= 0:
    alive = false
    died.emit(self)
    print("hero died")
  
func _integrate_forces(state:PhysicsDirectBodyState2D):
  if _health >= 0:
    state.linear_velocity = _move_direction * data.speed

func _process(delta):
  _move_direction = Vector2.ZERO

  if _health > 0:
    if Input.is_action_pressed("ui_right"):
      _move_direction += Vector2.RIGHT
    if Input.is_action_pressed("ui_left"):
      _move_direction += Vector2.LEFT
    if Input.is_action_pressed("ui_up"):
      _move_direction += Vector2.UP
    if Input.is_action_pressed("ui_down"):
      _move_direction += Vector2.DOWN

    _move_direction = _move_direction.normalized()


func _ready():
  _health = data.health
