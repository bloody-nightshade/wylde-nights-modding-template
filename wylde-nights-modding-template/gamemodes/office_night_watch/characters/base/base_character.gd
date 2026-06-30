class_name BaseCharacter extends Node
## [BaseCharacter] is the foundation every character is built on.
##
## On it's own [BaseCharacter] doesn't do anything and requires scripting via Subclasses be them the ones already created e.g. [PathCharacter] or making one yourself.[br]
## The scene on a character's CharacterData should instantiate one of these (or a subclass).


#region Signals
@warning_ignore("unused_signal")
## A move completes. Some subclasses also emit this with both args being the same to cause camera fuzz without actually moving.
signal movement_succeeded(previous_location: GameConstants.CameraID, current_location: GameConstants.CameraID) 
## A movement roll fails.
signal movement_failed(current_location: GameConstants.CameraID)
## An attack begins (via [method attack]).
signal attack_succeeded(character: BaseCharacter, position: GameConstants.OfficePosition, animation: String)
## An attack is blocked (via [method failed_attack]).
signal attack_failed(door: GameConstants.OfficePosition)
## [member state] changes value.
signal state_changed(state: CharacterState)
#endregion

#region Parameters
## The character's ID, set when it's loaded. Used in warning/error messages.
var character_id: String = ""

## The current location of the character.[br]
## By default this sets the character's position at the start of the night.
@export var current_location: GameConstants.CameraID = GameConstants.CameraID.CAM_4

## Active/inactive state. Setting it emits [signal state_changed].
var state: CharacterState = CharacterState.INACTIVE:
	set(value):
		if state == value:
			return
		state = value
		state_changed.emit(state)

@export_group("Watched Times")
## Whether the player is currently viewing this character's camera. Setting it calls [method on_watched_changed].
var currently_watched: bool = false:
	set(value):
		if currently_watched == value:
			return
		currently_watched = value
		on_watched_changed()

## Lower bound that [member time_watched] decays toward while unwatched.
@export var min_time_watched: float = 0.0
## Upper bound that [member time_watched] climbs toward while watched
@export var max_time_watched: float = 0.0
## Ramps between [member min_time_watched] and [member max_time_watched] based on [member currently_watched].
var time_watched: float = 0.0

## The character's AI level for the night. [code]0[/code] = inactive.
var difficulty: int = 0
## How many movement rolls have failed in a row and influences the next movement opportunity rng check.
var failed_movements: int = 0
#endregion

#region Enums

enum CharacterState {
	INACTIVE, ## Asleep - _process does nothing.
	ACTIVE, ## Awake - _process runs like normal.
}

#endregion

#region Lifecycle

func _ready() -> void:
	if difficulty == 0:
		set_state(CharacterState.INACTIVE)
	else:
		set_state(CharacterState.ACTIVE)

func _process(delta: float) -> void:
	if state == CharacterState.INACTIVE:
		return
	
	update_watched_status(delta)

## Returns the current difficulty of this character.
func get_difficulty() -> int:
	return difficulty

## Sets the current difficulty of this character.
func set_difficulty(_difficulty: int):
	difficulty = _difficulty

## Returns the current state of this character.
func get_state() -> BaseCharacter.CharacterState:
	return state

## Sets the current state of this character.
func set_state(_state: BaseCharacter.CharacterState) -> void:
	state = _state

#endregion

#region Movement

## This has the [member difficulty] + [member failed_movements] compared against a random range between [code]1[/code] to [code]20[/code].[br]
## Returns [code]true[/code] if [member difficulty] + [member failed_movements] is greater than the random number and sets [member failed_movements] to [code]0[/code] Returns [code]false[/code] otherwise and adds [code]1[/code] to [member failed_movements]
func movement_opportunity() -> bool:
	if get_difficulty() + failed_movements >= randi_range(1, 20):
		failed_movements = 0
		return true
	else:
		failed_movements += 1
		return false

## Runs [method movement_opportunity] and depending if it runs [code]true[/code] or [code]false[/code] it will either call [method movement] or [method failed_movement].[br]
## This is what you call for when a character should try to move e.g. [class Starburst] would call this every 5 seconds.
func attempt_movement() -> void:
	if movement_opportunity():
		movement()
	else:
		failed_movement()

## This gets called when a character succeeds a [method attempt_movement]
## This does nothing, this is intended to be overridden.
## This is what you should use for moving the character themselves.
func movement() -> void:
	pass

##This gets called when a character fails a [method attempt_movement]
## This only emits [signal movement_failed]. This can be overridden for additional functionality.
func failed_movement() -> void:
	movement_failed.emit(current_location)

## This is intended to be called when a character reaches the end of the path but is forced to go back to the start.[br]
## e.g. [class Starburst] being sent back to Camera 4 when they reach the right door and find it closed.
func reset() -> void:
	pass

## Returns the character's current location.
func get_current_location() -> GameConstants.CameraID:
	return current_location

## Sets the character's current location.
func set_current_location(cam_id = GameConstants.CameraID) -> void:
	current_location = cam_id

## Checks the current character's location and returns [code]true[/code] or [code]false[/code].
## This returns [code]true[/code] if [member current_location] is either [enum GameConstants.LEFT_DOOR] or [enum GameConstants.RIGHT_DOOR].
func is_at_door() -> bool:
	return get_current_location() in [GameConstants.CameraID.LEFT_DOOR, GameConstants.CameraID.RIGHT_DOOR]

#endregion

#region Watched
## Increment or decrements [member time_watched] based on how long the player watches them for. This can be overriden to change the rate of the increment or decrement.
func update_watched_status(delta: float) -> void:
	if get_watched():
		time_watched = min(time_watched + delta, max_time_watched)
	else:
		time_watched = max(time_watched - delta, min_time_watched)

## This returns the value of [member currently_watched].
func get_watched() -> bool:
	return currently_watched

## This sets the value of [member currently_watched].
func set_watched(watched: bool) -> void:
	currently_watched = watched

## This gets called whenever the [member currently_watched] value changes. [br]
## This is intended to be overridden for you to run some logic based on whenever someone's watched status changes.
func on_watched_changed() -> void:
	pass
#endregion

#region Sprite States
## Returns "idle" by default.[br]
## Override this if you want your character to visually have different stages e.g. An earlier version of [Luci] having an aggression mechanic based on you watching her.
func get_camera_state() -> String:
	return "idle"

## By default this returns:[br]
## - "idle" if not at one of the doors.[br]
## - "open" if at a door but it is open.[br]
## - "closed" if at a door but it is closed.[br]
## Override this if you want your character to visually have different stages.
func get_office_state() -> String:
	if !is_at_door():
		return "idle"
	
	var current_door = GameConstants.parse_cam_id_to_office_pos(get_current_location())
	
	if OfficeNightWatchManager.instance.is_door_open(current_door):
		return "open"
	
	return "closed"
#endregion

#region Attacking
## This is a function that is intended to be overridden. This is to be ran when the character is poised to attack and is to check if they can attack.[br]
## e.g. Starburst's [method Starburst.attempt_attack] checking if the right door is open or closed.
func attempt_attack(_office_position: GameConstants.OfficePosition) -> void:
	pass

func attack(office_position: GameConstants.OfficePosition, animation: String = "default") -> void:
	attack_succeeded.emit(self, office_position, animation)
	OfficeNightWatchManager.instance.on_attack_started(self, animation)

func failed_attack(office_position: GameConstants.OfficePosition) -> void:
	attack_failed.emit(office_position)
	reset()
#endregion
