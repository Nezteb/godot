class_name DestructibleMeshInstance extends MeshInstance3D

@export var hurtbox: Hurtbox3D
@export var destructible: Destructible


func get_custom_class() -> String:
	return "DestructibleMeshInstance"
	
	
func _ready():
	assert(hurtbox is Hurtbox3D, "DestructibleMeshInstance: This node needs a hurtbox to detect hitboxes that triggers destroy method")
	assert(destructible is Destructible, "DestructibleMeshInstance: This node needs a destructible class")
	
	if destructible.target == null:
		destructible.target = self
		
	hurtbox.hitbox_detected.connect(on_hitbox_detected)


func on_hitbox_detected(hitbox: Hitbox3D):
	## This is a temporary placeholder to test the destructible, logic can be different
	if hitbox.get_parent() is Throwable3D:
		destructible.destroy()
