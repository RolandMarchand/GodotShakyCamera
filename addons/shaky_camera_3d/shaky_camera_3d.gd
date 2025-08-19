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
## How many degrees in radians max does the screen roll.
## Setting to 0 as well as [member shake_shift_intensity] disables shake processing
## and resets the camera's position and rotation to 0.
@export_range(0, 2, 0.01) var shake_roll_intensity := 0.12:
	set = set_shake_roll_intensity
## How quickly does the screen shift and roll.
## Setting to 0 disables shake processing and resets the camera's position and rotation to 0.
@export_range(0, 20, 0.01) var shake_speed := 10.0:
	set = set_shake_speed

var _time: float

func _enter_tree():
	_noise.frequency = 0.1


func _process(delta):
	_time += delta * shake_speed
	var shake_x = _noise.get_noise_2d(_time, 0) * shake_shift_intensity
	var shake_y = _noise.get_noise_2d(0, _time) * shake_shift_intensity / 2.0
	position = Vector3(shake_x, shake_y, 0);
	rotation.z = _noise.get_noise_3d(0, 0, _time) * shake_roll_intensity


# Reset the camera position and rotation to 0 when there is no shake.
# Also, disable [method _process] which contains the shaking logic when there is no shake.
func _shake_handle_state():
	if shake_speed > 0 and (shake_roll_intensity > 0 or shake_shift_intensity > 0):
		set_process(true)
	else:
		set_process(false)
		position = Vector3.ZERO
		rotation.z = 0


func set_shake_shift_intensity(shift: float):
	shake_shift_intensity = shift
	_shake_handle_state()


func set_shake_roll_intensity(roll: float):
	shake_roll_intensity = roll
	_shake_handle_state()


func set_shake_speed(speed: float):
	shake_speed = speed
	_shake_handle_state()
