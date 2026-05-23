class_name BaseCharacter extends Node

var character_id: String = ""

## This sets the default position of the character at the start of the night
@export var current_location: GameConstants.CameraID = GameConstants.CameraID.CAM_4

enum CharacterState {
	INACTIVE,
	ACTIVE,
}

var state: CharacterState = CharacterState.INACTIVE:
	set(value):
		if state == value:
			return
		state = value
		state_changed.emit(state)

var currently_watched: bool = false
@export var min_time_watched: float = 0.0
@export var max_time_watched: float = 0.0
var time_watched: float = 0.0

var difficulty: int = 0
var failed_movements: int = 0

signal movement_succeeded(previous_location: GameConstants.CameraID, current_location: GameConstants.CameraID, camera_static: bool)
signal movement_failed(current_location: GameConstants.CameraID)
signal attack_succeeded(character: BaseCharacter, position: GameConstants.OfficePosition, animation: String)
signal attack_failed(door: GameConstants.OfficePosition)
signal state_changed(state: CharacterState)

func _ready() -> void:
	if difficulty == 0:
		state = CharacterState.INACTIVE
	else:
		state = CharacterState.ACTIVE

func _process(delta: float) -> void:
	if state == CharacterState.INACTIVE:
		return
	
	update_watched_status(delta)

func movement_opportunity() -> bool:
	if get_current_difficulty() + failed_movements >= randi_range(1, 20):
		failed_movements = 0
		return true
	else:
		failed_movements += 1
		return false

func attempt_movement() -> void:
	if movement_opportunity():
		movement()
	else:
		failed_movement()

func movement() -> void:
	pass

func failed_movement() -> void:
	movement_failed.emit(current_location)

func update_watched_status(delta: float) -> void:
	if currently_watched:
		time_watched = min(time_watched + delta, max_time_watched)
	else:
		time_watched = max(time_watched - delta, min_time_watched)

func get_current_location() -> GameConstants.CameraID:
	return current_location

func get_current_difficulty() -> int:
	return difficulty

func set_difficulty(_difficulty: int):
	difficulty = _difficulty

func set_watched(watched: bool) -> void:
	if currently_watched == watched:
		return
	currently_watched = watched
	on_watched_changed(watched)

func on_watched_changed(watched: bool) -> void:
	currently_watched = watched

func attempt_attack(_office_position: GameConstants.OfficePosition) -> void:
	pass

func attack(office_position: GameConstants.OfficePosition, animation: String = "default") -> void:
	attack_succeeded.emit(self, office_position, animation)
	OfficeNightWatchManager.instance.on_attack_started(self, animation)

func failed_attack(office_position: GameConstants.OfficePosition) -> void:
	attack_failed.emit(office_position)
	reset()

func reset() -> void:
	pass

func get_camera_state() -> String:
	return "idle"
