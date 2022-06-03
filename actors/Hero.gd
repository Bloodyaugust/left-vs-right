extends RigidDynamicBody2D

@export var data:Resource
@export var team:int

func damage(amount:float) -> void:
  print("hero damaged: %.2f" % amount)
