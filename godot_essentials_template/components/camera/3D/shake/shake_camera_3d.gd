@icon("res://components/camera/2D/shake/shake_camera.svg")
class_name ShakeCamera3D extends Camera3D

@export var trauma_reduction_rate := 1.0
@export var max_rotation_x := 10.0
@export var max_rotation_y := 10.0
@export var max_rotation_z := 5.0
@export var noise_speed := 50.0
@export var noise_type := FastNoiseLite.TYPE_PERLIN:
	set(value):
		if value != noise_type && is_node_ready():
			noise.noise_type = value
			randomize()
			noise.seed = randi()
			
		noise_type = value
## Controls the number of noise layers (detail)
@export var noise_fractal_octaves = 1
## Controls the spacing between the frequencies of those layers (smoothness vs. roughness).
@export var noise_lacunarity = 1.0

@onready var noise = FastNoiseLite.new()

var trauma := 0.0
var time := 0.0

var trauma_timer: Timer
var initial_rotation: Vector3
var current_trauma := 0.0 ## This variable works to keep adding trauma while the timer is active

func _ready():
	set_process(false)
	_create_trauma_timer()
	initial_rotation = rotation_degrees
	noise.fractal_octaves = noise_fractal_octaves ## controls the number of noise layers (detail).
	noise.fractal_lacunarity = noise_lacunarity ## 
	
	
func _process(delta):
	if trauma_timer.time_left > 0 and trauma == 0:
		trauma = current_trauma
		
	time += delta
	trauma = max(0, trauma - delta * trauma_reduction_rate)
	var intensity = shake_intensity()
	
	rotation_degrees = Vector3(
		initial_rotation.x + max_rotation_x * intensity * get_noise_from_seed(0), 
		initial_rotation.y + max_rotation_y * intensity * get_noise_from_seed(1), 
		initial_rotation.z + max_rotation_z * intensity * get_noise_from_seed(2)
	)

	
func add_trauma(amount: float, _time: float):
	trauma = clamp(trauma + amount, 0, 1.0)
	current_trauma = trauma
	
	if(is_instance_valid(trauma_timer)):
		trauma_timer.stop()
		trauma_timer.wait_time = max(0.05, _time)
		trauma_timer.start(time)
	
	set_process(true)
	
func shake_intensity() -> float:
	return trauma * trauma
	
	
func get_noise_from_seed(_seed: int) -> float:
	noise.seed = _seed
	
	return noise.get_noise_1d(time * noise_speed)
	

func finish_trauma():
	time = 0
	current_trauma = 0
	set_process(false)
	
	
func _create_trauma_timer():
	if trauma_timer == null:
		trauma_timer = Timer.new()
		trauma_timer.name = "FoostepIntervalTimer"
		trauma_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		trauma_timer.autostart = false
		trauma_timer.one_shot = true
		
		add_child(trauma_timer)
		trauma_timer.timeout.connect(on_trauma_timer_timeout)



func on_trauma_timer_timeout():
	finish_trauma()
