class_name OfficeNightWatchManager extends Node
## Runs a single night of gameplay. [br]
## Other systems use the information found here and call into it to toggle cameras and doors, and it reports everything back out through signals.

## The currently active instance, set while this node is in the tree.
static var instance: OfficeNightWatchManager

#region Signals
## Emitted whenever [member current_power] or [member max_power] changes.
signal power_changed(current_power: float, max_power: float)
## Emitted when [member current_power] reaches zero.
signal power_depleted()

## Emitted when the player survives until the end of the night.
signal night_over()

## Emitted once for every in-game minute that elapses.
signal minute_passed(minute: int)
## Emitted once for every in-game hour that elapses.
signal hour_passed(hour: int)

## Emitted when the camera view is raised or lowered.
signal cameras_toggled(cameras_active: bool)
## Emitted when the player switches to a different camera feed.
signal camera_changed(cam_id: GameConstants.CameraID)

## Emitted when a door is opened or closed.
signal door_state_changed(side: GameConstants.OfficePosition, state: GameConstants.DoorState)

## Emitted when a loaded character moves from one camera location to another.
signal character_moved(character: BaseCharacter, old_position: GameConstants.CameraID, new_position: GameConstants.CameraID)

## Emitted when a character begins its attack on the player.
signal attack_started()
#endregion


#region State

## The night to use when this scene is run directly instead of through [code]GameManager[/code].
@export var default_night: int = 1
## The night currently being played.
var night: int = 1

## Number of in-game minutes that make up one in-game hour.
const HOUR_LENGTH: int = 60

@export_group("Time")
## The minute within [member end_hour] at which the night ends.[br]
## Must not exceed [member HOUR_LENGTH], larger values are rejected and logged as a warning.
@export var end_minute: int = 0:
	set(value):
		if value > HOUR_LENGTH:
			push_warning("OfficeNightWatchManager: Attempted to change end_minute (%d) to be higher than HOUR_LENGTH (%d)" % [value, HOUR_LENGTH])
			return
		
		if value != end_minute:
			end_minute = value
## The hour at which the night ends.
@export var end_hour: int = 6
## Accumulates elapsed real time (in seconds) and calls [method tick] once per second.
var time_passed: float = 0.0
## The current minute within [member current_hour].
var current_minute: int = 0
## The current hour of the night.
var current_hour: int = 0

@export_group("Power")
## Power drained per second regardless of player activity.
@export var power_drain_idle: int = 0
## Extra power drained per second while the cameras are active.
@export var power_drain_cameras: int = 1
## Extra power drained per second for each closed door.
@export var power_drain_door: int = 2
## Maximum power for a full-length night, before it is scaled to the actual night length.
@export var base_max_power: float = 400

## The player's current power. Emits [signal power_changed] when set to a new value.
var current_power: float = 100.0:
	set(value):
		if current_power != value:
			current_power = value
			power_changed.emit(current_power, max_power)
## The player's maximum power, scaled from [member base_max_power] by night length. Emits [signal power_changed] when set to a new value.
var max_power: float = 100.0:
	set(value):
		if max_power != value:
			max_power = value
			power_changed.emit(current_power, max_power)

@export_group("Cameras")
## Whether the camera view is currently active.
var cameras_active: bool = false
## When [code]true[/code], the cameras can no longer be toggled.
var cameras_locked: bool = false
## The camera feed the player is currently viewing.[br]
## Setting it emits [signal camera_changed] and refreshes which characters are being watched.
@export var current_camera: GameConstants.CameraID = GameConstants.CameraID.CAM_4:
	set(value):
		var previous_camera = current_camera
		current_camera = value
		
		camera_changed.emit(current_camera)
		update_watched_status(previous_camera, current_camera)

## The open/closed state of the left and right doors.
var door_states: Dictionary[GameConstants.OfficePosition, GameConstants.DoorState] = {
	GameConstants.OfficePosition.LEFT_DOOR: GameConstants.DoorState.OPEN,
	GameConstants.OfficePosition.RIGHT_DOOR: GameConstants.DoorState.OPEN
}

## When [code]true[/code], the right door can no longer be toggled.
var right_door_locked: bool = false
## When [code]true[/code], the left door can no longer be toggled.
var left_door_locked: bool = false

## Every character active this night, keyed by character ID. Includes built-in and modded characters.
var characters: Dictionary[String, BaseCharacter] = {}

## Plays the jumpscare animation when a character attacks.
@onready var jumpscare_handler: AnimatedSprite2D = %JumpscareHandler
## Plays the jumpscare audio when a character attacks.
@onready var jumpscare_audio: AudioStreamPlayer2D = %JumpscareAudio
## ID of the character currently performing a jumpscare.
var attacking_character_id: String = "!"
#endregion


#region Lifecycle
func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	night = default_night
	
	# This function is a stub as it requires an Autoload that is not included in the modding template
	
	jumpscare_handler.animation_finished.connect(on_attack_ended)
	night_over.connect(on_night_over)
	
	spawn_characters()
	set_camera(current_camera)
	
	set_night_length()
	
	var night_length_seconds = (end_hour * HOUR_LENGTH) + end_minute
	var standard_night_length = 6 * HOUR_LENGTH
	max_power = base_max_power * (float(night_length_seconds) / float(standard_night_length))
	current_power = max_power

func _exit_tree() -> void:
	instance = null

func _process(delta: float) -> void:
	time_passed += delta
	
	if time_passed >= 1:
		time_passed -= 1
		tick()
	
	drain_power(delta)
#endregion


#region Night & Time

## Sets [member end_hour] from the current [member night].[br]
## Nights 1–3 are deliberately shorter as there is far less to do early on. The shortened length still gives the player enough time to learn the mechanics before the game gets harder.
func set_night_length() -> void:
	match night:
		1:
			end_hour = 3
		2:
			end_hour = 4
		3:
			end_hour = 5
		_:
			end_hour = 6

## Advances the clock by one in-game minute, when [member current_minute] is greater than [member HOUR_LENGTH].[br]
## Emits [signal minute_passed] every minute, [signal hour_passed] on each new hour, and [signal night_over] once [member end_hour] and [member end_minute] are reached.
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

## Returns how far the night has progressed, from [code]0.0[/code] at the start of the night to [code]1.0[/code] at the end of the night.
func get_night_progress() -> float:
	var total: int = end_hour * HOUR_LENGTH + end_minute
	
	if total <= 0:
		return 0.0
	
	var current: int = current_hour * HOUR_LENGTH + current_minute
	
	return clampf(float(current) / float(total), 0.0, 1.0)
#endregion


#region Characters

## Instantiates every registered character for this night and adds it to the scene.[br]
## Also sets the character's difficulty based on their defaults for the current [member night][br]
## If it is currently Night 7, it gets set to the custom difficulties.
func spawn_characters() -> void:
	pass
	
	# This function is a stub as it requires an Autoload that is not included in the modding template

## Returns every character currently located at [param cam_id].
func get_characters_in_camera(cam_id: GameConstants.CameraID) -> Array[BaseCharacter]:
	var result: Array[BaseCharacter] = []
	result.assign(characters.values().filter(
		func(character: BaseCharacter): 
			return character.get_current_location() == cam_id
	))
	return result
#endregion


#region Power
## Reduces [member current_power] for this frame by the current drain rate, clamped at zero.[br]
## Emits [signal power_depleted] and runs [method on_power_depleted] once power hits zero.
func drain_power(delta: float) -> void:
	var rate = get_drain_rate()
	current_power = maxf(current_power - rate * delta, 0.0)
	
	if current_power <= 0.0:
		power_depleted.emit()
		on_power_depleted()

## Returns the total power drained per second given the current camera and door usage.
func get_drain_rate() -> int:
	var rate = power_drain_idle
	
	if cameras_active:
		rate += power_drain_cameras
	
	if is_door_closed(GameConstants.OfficePosition.LEFT_DOOR):
		rate += power_drain_door
	
	if is_door_closed(GameConstants.OfficePosition.RIGHT_DOOR):
		rate += power_drain_door
	
	return rate

## Locks the cameras and both doors once the player has run out of power.
func on_power_depleted():
	lock_cameras()
	lock_door(GameConstants.OfficePosition.LEFT_DOOR, true)
	lock_door(GameConstants.OfficePosition.RIGHT_DOOR, true)
#endregion


#region Cameras
## Turns on/off the cameras, unless they are locked, and updates which characters are being watched.
func toggle_cameras() -> void:
	if cameras_locked:
		return
	cameras_active = !cameras_active
	cameras_toggled.emit(cameras_active)
	
	if not cameras_active:
		update_watched_status(current_camera, GameConstants.CameraID.OFFICE)
	else:
		update_watched_status(GameConstants.CameraID.OFFICE, current_camera)

## Locks the cameras so that the player cannot toggle them.[br]
## If [param force_down] is [code]true[/code] the cameras are forcibly disabled.
func lock_cameras(force_down: bool = true) -> void:
	if force_down:
		force_cameras_down()
	
	cameras_locked = true

## Unlocks the cameras so they can be toggled again.
func unlock_cameras() -> void:
	cameras_locked = false

## Lowers the cameras if they are currently raised, clearing the watched status of any characters on the active feed.
func force_cameras_down() -> void:
	if cameras_active:
		cameras_active = false
		cameras_toggled.emit(false)
		
		for character in get_characters_in_camera(current_camera):
			character.set_watched(false)

## Switches the active camera to [param cam_id].
func set_camera(cam_id: GameConstants.CameraID) -> void:
	current_camera = cam_id

## Returns the camera the player is currently viewing.
func get_camera() -> GameConstants.CameraID:
	return current_camera

## Marks characters in [param previous] as unwatched and characters in [param current] as watched.
func update_watched_status(previous: GameConstants.CameraID, current: GameConstants.CameraID) -> void:
	for character in get_characters_in_camera(previous):
		character.set_watched(false)
	for character in get_characters_in_camera(current):
		character.set_watched(true)
#endregion


#region Doors

## Opens or closes [param side] based on its current state, unless that door is locked.
func toggle_door(side: GameConstants.OfficePosition) -> void:
	
	if side == GameConstants.OfficePosition.LEFT_DOOR && left_door_locked:
		return
	elif side == GameConstants.OfficePosition.RIGHT_DOOR && right_door_locked:
		return
	
	var current_state: GameConstants.DoorState = get_door_state(side)
	var new_state: GameConstants.DoorState
	if current_state == GameConstants.DoorState.OPEN:
		new_state = GameConstants.DoorState.CLOSED
	else:
		new_state = GameConstants.DoorState.OPEN
	
	door_states[side] = new_state
	
	door_state_changed.emit(side, new_state)

## Returns the current state of [param side].
func get_door_state(side: GameConstants.OfficePosition) -> GameConstants.DoorState:
	return door_states[side]

## Returns [code]true[/code] if [param side] is open.
func is_door_open(side: GameConstants.OfficePosition) -> bool:
	return door_states[side] == GameConstants.DoorState.OPEN

## Returns [code]true[/code] if [param side] is closed.
func is_door_closed(side: GameConstants.OfficePosition) -> bool:
	return door_states[side] == GameConstants.DoorState.CLOSED

## Opens [param side] if it is currently closed.
func force_open_door(side: GameConstants.OfficePosition) -> void:
	if is_door_closed(side):
		toggle_door(side)

## Locks [param side] so it can no longer be toggled.[br]
## When [param force_open] is [code]true[/code], the door is opened first.
func lock_door(side: GameConstants.OfficePosition, force_open: bool = true) -> void:
	if force_open:
		force_open_door(side)
	
	if side == GameConstants.OfficePosition.LEFT_DOOR:
		left_door_locked = true
	elif side == GameConstants.OfficePosition.RIGHT_DOOR:
		right_door_locked = true
	

## Unlocks [param side] so it can be toggled once more.
func unlock_door(side: GameConstants.OfficePosition) -> void:
	if side == GameConstants.OfficePosition.LEFT_DOOR:
		left_door_locked = false
	elif side == GameConstants.OfficePosition.RIGHT_DOOR:
		right_door_locked = false
#endregion

#region Attack & Endings

## Begins a character's jumpscare: locks down the office, clears the other characters, and plays the attacking character's animation and audio.
func on_attack_started(character: BaseCharacter, animation: String) -> void:
	pass
	
	# This function is a stub as it requires an Autoload that is not included in the modding template

## Sends the player to the game over screen.
func on_attack_ended() -> void:
	pass
	
	# This function is a stub as it requires an Autoload that is not included in the modding template

## Sends the player to the win screen.
func on_night_over() -> void:
	night_over.emit()
	
	pass
	
	# This function is a stub as it requires an Autoload that is not included in the modding template
#endregion
