extends Node2D

@export var data:Resource

@onready var _attack_animator:AnimationPlayer = %AttackAnimator
@onready var _attack_areas_container:Node2D = %AttackAreas
@onready var _attack_sprite:Sprite2D = %Sprite2D
@onready var _attack_areas:Array = _attack_areas_container.get_children()
@onready var _parent:Node2D = get_parent()

var _attack_area_bodies:Dictionary = {}
var _current_attack_area:int = 0
var _time_to_attack:float = 0.0

func attack() -> void:
  for _body in _attack_area_bodies[_attack_areas[_current_attack_area]]:
    _body.damage(data.damage)

  _attack_sprite.global_position = _attack_areas[_current_attack_area].global_position
  _attack_animator.play("attack")
  _time_to_attack = data.attack_interval
  _current_attack_area = wrapi(_current_attack_area + 1, 0, len(_attack_areas))

func _on_attack_area_body_entered(attack_area:Area2D, body:Node2D) -> void:
  if body != _parent:
    _attack_area_bodies[attack_area].append(body)

func _on_attack_area_body_exited(attack_area:Area2D, body:Node2D) -> void:
  if body != _parent:
    _attack_area_bodies[attack_area] = _attack_area_bodies[attack_area].filter(func(existing_body): return existing_body != body)

func _physics_process(delta):
  _time_to_attack = clampf(_time_to_attack - delta, 0.0, data.attack_interval)

  if _time_to_attack <= 0:
    attack()

func _ready():
  _attack_sprite.texture = data.attack_sprite
  _attack_sprite.visible = false

  for _attack_area in _attack_areas:
    _attack_area_bodies[_attack_area] = []
    _attack_area.body_entered.connect(func(body:Node2D): _on_attack_area_body_entered(_attack_area, body))
    _attack_area.body_exited.connect(func(body:Node2D): _on_attack_area_body_exited(_attack_area, body))
