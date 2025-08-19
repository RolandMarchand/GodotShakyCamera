@tool
extends Camera3D
class_name ShakyCamera3D

## Camera that shakes.
##
## This node is an extension of [Camera3D] with shaking built-in.
## Shaking can be disabled by setting either [member speed]
## or [member shake_shift_intensity] and [member shake_roll_intensity] to 0.

var _noise := FastNoiseLite.new()
@export_group("Shake", "shake_")
## How far on the view plane does the screen shake.
## Setting to 0 as well as [member shake_roll_intensity] disables shake processing
## and resets the camera's position and rotation to 0.
@export_range(0, 5, 0.01) var shake_shift_intensity := 0.81:
	set = set_shake_shift_intensity
## How many degrees max does the screen roll.
## Setting to 0 as well as [member shake_shift_intensity] disables shake processing
## and resets the camera's position and rotation to 0.
@export_range(0, 360, 0.01) var shake_roll_intensity := 10.0:
	set = set_shake_roll_intensity
## How quickly does the screen shift and roll.
## Setting to 0 disables shake processing and resets the camera's position and rotation to 0.
@export_range(0, 30, 0.01) var shake_speed := 10.0:
	set = set_shake_speed
## After resetting to 0, the shaking pattern will repeat. Changing this seed
## also changes the shaking pattern, if the default one isn't up to your liking.
@export var shake_randomness_seed := 1:
	set = set_shake_randomness_seed

var _time := 0.0

func _enter_tree():
	_noise.frequency = 0.1
	_noise.seed = shake_randomness_seed


func _ready():
	_shake_handle_state()


## Shake camera in one short burst with [member time] duration.
## Then, reset back to 0. [member shift_intensity] is the maximum the camera can
## move horizontally in meters, while [member shift_intensity] is how far the
## camera will roll in degrees.
func impulse(shift_intensity, roll_intensity, time) -> void:
	var tween_shift = get_tree().create_tween().bind_node(self)
	tween_shift.tween_property(self, "shake_shift_intensity", shift_intensity, time / 5.0)
	var tween_roll = tween_shift.parallel()
	tween_roll.tween_property(self, "shake_roll_intensity", roll_intensity, time / 5.0)
	tween_shift.tween_property(self, "shake_shift_intensity", 0, time)
	tween_roll.tween_property(self, "shake_roll_intensity", 0, time * 0.8)


func _process(delta):
	_time += delta * shake_speed
	var shake_x = _noise.get_noise_2d(_time, 0) * shake_shift_intensity
	var shake_y = _noise.get_noise_2d(0, _time) * shake_shift_intensity / 2.0
	position = Vector3(shake_x, shake_y, 0);
	rotation.z = _noise.get_noise_3d(0, 0, _time) * deg_to_rad(shake_roll_intensity)


# Reset the camera position and rotation to 0 when there is no shake.
# Also, disable [method _process] which contains the shaking logic when there is no shake.
func _shake_handle_state():
	if shake_speed > 0 and (shake_roll_intensity > 0 or shake_shift_intensity > 0):
		set_process(true)
	else:
		set_process(false)
		position = Vector3.ZERO
		rotation.z = 0
		_time = 0


func set_shake_shift_intensity(shift: float):
	shake_shift_intensity = shift
	_shake_handle_state()


func set_shake_roll_intensity(roll: float):
	shake_roll_intensity = roll
	_shake_handle_state()


func set_shake_speed(speed: float):
	shake_speed = speed
	_shake_handle_state()


func set_shake_randomness_seed(seed: int):
	shake_randomness_seed = seed
	_noise.seed = seed
