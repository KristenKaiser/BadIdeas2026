extends MeshInstance3D

@export var sub_viewport : SubViewport
#var mesh
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var material = StandardMaterial3D.new()
	var viewport_texture = sub_viewport.get_texture()
	material.albedo_texture = viewport_texture
	material.emission_enabled = true
	material.emission_texture = viewport_texture
	material.emission_energy_multiplier = 2.0
	mesh.set_surface_override_material(0, material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
