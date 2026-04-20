## Hey, Listen!
## This script here doesn't exist to be modified or anything like that, it just exists to be used as references for your characters
## Basically this is read only
class_name OfficeNightWatchManager extends Node

static var instance: OfficeNightWatchManager

signal power_changed(current_power: float, max_power: float)
signal power_depleted()
signal night_over()
signal minute_passed(minute: int)
signal hour_passed(hour: int)
signal cameras_toggled(cameras_active: bool)
signal camera_changed(cam: GameConstants.CameraID)
signal door_state_changed(side: GameConstants.OfficePosition, state: GameConstants.DoorState)
signal character_moved(character: BaseCharacter, old_position: GameConstants.CameraID, new_position: GameConstants.CameraID)
signal attack_started()

var current_power: float = 100.0:
	set(value):
		current_power = value
		power_changed.emit(current_power, max_power)
var max_power: float = 100.0:
	set(value):
		max_power = value
		power_changed.emit(current_power, max_power)

const DRAIN_IDLE: int = 0
const DRAIN_CAMERAS: int = 1
const DRAIN_DOOR: int = 2

const BASE_MAX_POWER: float = 175.0

var night: int = 1

var time_passed: float = 0

const HOUR_LENGTH: int = 60

var current_minute: int = 0
var current_hour: int = 0

var end_minute: int = 0
var end_hour: int = 6

var cameras_active: bool = false
var cameras_locked: bool = false
var current_camera: GameConstants.CameraID = GameConstants.CameraID.CAM_4

var door_states: Dictionary[GameConstants.OfficePosition, GameConstants.DoorState] = {
	GameConstants.OfficePosition.LEFT_DOOR: GameConstants.DoorState.OPEN,
	GameConstants.OfficePosition.RIGHT_DOOR: GameConstants.DoorState.OPEN
}

var right_door_locked: bool = false
var left_door_locked: bool = false

var characters: Dictionary = {}

@onready var jumpscare_handler: AnimatedSprite2D = $JumpscareHandler

func _enter_tree() -> void:
	instance = self

func _exit_tree() -> void:
	instance = null

func _ready() -> void:
	# night = GameManager.pending_config.get("night", 1)
	night = 1
	
	jumpscare_handler.animation_finished.connect(on_attack_ended)
	night_over.connect(on_night_over)
	
	spawn_characters()
	set_camera(current_camera)
	
	
	var night_length_seconds = (end_hour * HOUR_LENGTH) + end_minute
	var standard_night_length = 6 * HOUR_LENGTH
	max_power = BASE_MAX_POWER * (night_length_seconds / standard_night_length)
	current_power = max_power

func _process(delta: float) -> void:
	time_passed += delta
	
	if time_passed >= 1:
		time_passed -= 1
		tick()
	
	drain_power(delta)

func tick() -> void:
	current_minute += 1
	
	if current_minute >= HOUR_LENGTH:
		current_minute -= HOUR_LENGTH
		current_hour += 1
		hour_passed.emit(current_hour)
	
	minute_passed.emit(current_minute)
	
	if current_hour >= end_hour:
		if current_minute >= end_minute:
			night_over.emit()

func drain_power(delta: float) -> void:
	var rate = get_drain_rate()
	current_power = maxf(current_power - rate * delta, 0.0)
	
	if current_power <= 0.0:
		power_depleted.emit()
		on_power_depleted()

func get_drain_rate() -> int:
	var rate = DRAIN_IDLE
	
	if cameras_active:
		rate += DRAIN_CAMERAS
	
	if is_door_closed(GameConstants.OfficePosition.LEFT_DOOR):
		rate += DRAIN_DOOR
	
	if is_door_closed(GameConstants.OfficePosition.RIGHT_DOOR):
		rate += DRAIN_DOOR
	
	return rate

func on_power_depleted():
	lock_cameras()
	lock_door(GameConstants.OfficePosition.LEFT_DOOR, true)
	lock_door(GameConstants.OfficePosition.RIGHT_DOOR, true)

func get_characters_in_camera(cam_id: GameConstants.CameraID) -> Array[BaseCharacter]:
	var result: Array[BaseCharacter] = []
	result.assign(characters.values().filter(
		func(character: BaseCharacter): 
			return character.get_current_location() == cam_id
	))
	return result

func spawn_characters() -> void:
	pass
	# Straight up had to get rid of this whole thing because it practically relied on a Character Registry script not included with this modding template

func toggle_cameras() -> void:
	if cameras_locked:
		return
	cameras_active = !cameras_active
	cameras_toggled.emit(cameras_active)
	
	if not cameras_active:
		for character in get_characters_in_camera(current_camera):
			character.set_watched(false)
	else:
		update_watched_status(GameConstants.CameraID.OFFICE, current_camera)

func lock_cameras() -> void:
	cameras_locked = true
	force_cameras_down()

func unlock_cameras() -> void:
	cameras_locked = false

func force_cameras_down() -> void:
	if cameras_active:
		cameras_active = false
		cameras_toggled.emit(false)
		
		for character in get_characters_in_camera(current_camera):
			character.set_watched(false)

func set_camera(cam: GameConstants.CameraID) -> void:
	var previous = current_camera
	current_camera = cam
	camera_changed.emit(current_camera)
	update_watched_status(previous, current_camera)

func get_camera() -> GameConstants.CameraID:
	return current_camera

func update_watched_status(previous: GameConstants.CameraID, current: GameConstants.CameraID) -> void:
	for character in get_characters_in_camera(previous):
		character.set_watched(false)
	for character in get_characters_in_camera(current):
		character.set_watched(true)

func toggle_door(side: GameConstants.OfficePosition) -> void:
	
	if side == GameConstants.OfficePosition.LEFT_DOOR && left_door_locked:
		return
	elif side == GameConstants.OfficePosition.RIGHT_DOOR && right_door_locked:
		return
	
	var current_state: GameConstants.DoorState = door_states[side]
	var new_state: GameConstants.DoorState
	if current_state == GameConstants.DoorState.OPEN:
		new_state = GameConstants.DoorState.CLOSED
	else:
		new_state = GameConstants.DoorState.OPEN
	
	door_states[side] = new_state
	
	door_state_changed.emit(side, new_state)

func get_door_state(side: GameConstants.OfficePosition) -> GameConstants.DoorState:
	return door_states[side]

func is_door_open(side: GameConstants.OfficePosition) -> bool:
	return door_states[side] == GameConstants.DoorState.OPEN

func is_door_closed(side: GameConstants.OfficePosition) -> bool:
	return door_states[side] == GameConstants.DoorState.CLOSED

func force_open_door(side: GameConstants.OfficePosition) -> void:
	if is_door_closed(side):
		toggle_door(side)

func lock_door(side: GameConstants.OfficePosition, force_open: bool = true) -> void:
	if force_open:
		force_open_door(side)
	
	if side == GameConstants.OfficePosition.LEFT_DOOR:
		left_door_locked = true
	elif side == GameConstants.OfficePosition.RIGHT_DOOR:
		right_door_locked = true
	

func unlock_door(side: GameConstants.OfficePosition) -> void:
	if side == GameConstants.OfficePosition.LEFT_DOOR:
		left_door_locked = false
	elif side == GameConstants.OfficePosition.RIGHT_DOOR:
		right_door_locked = false


func on_attack_started(character: BaseCharacter, animation: String) -> void:
	lock_cameras()
	lock_door(GameConstants.OfficePosition.LEFT_DOOR, false)
	lock_door(GameConstants.OfficePosition.RIGHT_DOOR, false)
	attack_started.emit()
	
	for id in characters:
		if characters[id] != character:
			characters[id].queue_free()
	characters.clear()
	characters[character.character_id] = character
	
	#var data = CharacterRegistry.get_character(character.character_id)
	
	#jumpscare_handler.sprite_frames = data.jumpscare_animation
	jumpscare_handler.play(animation)

func on_attack_ended() -> void:
	pass
	#GameManager.go_to_game_over(night, characters.keys()[0], current_hour * HOUR_LENGTH + current_minute)

func on_night_over() -> void:
	pass
	# GameManager.go_to_win_screen(night)
