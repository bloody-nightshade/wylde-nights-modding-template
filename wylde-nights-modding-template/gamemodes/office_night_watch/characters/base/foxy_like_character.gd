class_name FoxyLikeCharacter extends BaseCharacter

var stage: int = 0:
	set(value):
		if stage != value:
			stage = value
			stage_changed.emit(value)
			movement_succeeded.emit(get_current_location(), get_current_location()) # Done mostly for camera fuzz, I hope this doesn't have unforeseen consequences

@export var total_stages: int = 2 ## This is how many stages a character can go through before attacking. e.g. if the total_stages is at 2 then the character would need to go through stage 0, 1, 2 and then charging when their stage is greater than 2
@export var stage_timer_duration: float = 10.0 ## How much base time before each stage is incremented
var stage_timer: float = 0
@export var target_door: GameConstants.OfficePosition = GameConstants.OfficePosition.LEFT_DOOR

@export var charge_type: ChargeType = ChargeType.AUDIO_STREAM ## Determines how the charge is ran. AUDIO_STREAM requires overriding play_charge_audio() as well as adding a AudioStreamPlayer2D to the scene of the character
@export var charge_duration: float = 5.0 ## When charge_type is set to TIMER, this is how much time after reaching the final stage before the charge ends
var charge_timer: float = 0.0
var is_charging: bool = false

@export var freeze_condition: FreezeCondition = FreezeCondition.WHEN_CAMERA_VIEWED ## The condition required for manipulating the stage timer
@export var freeze_effect: FreezeEffect = FreezeEffect.FROZEN ## Only active when freeze_condition is WHEN_CAMERA_VIEWED or WHEN_CAMERAS_ACTIVE
@export var slow_multiplier: float = 0.5 ## How much the stage timer delta is affected

@export var linger_freeze_time: bool = false ## Makes it so that the whole freeze time thing can continue for a little bit longer
@export var linger_min: float = 0.0
@export var linger_max: float = 1.0
var is_lingering: bool = false
var linger_timer: float = 0.0

@export var use_movement_opportunity = true ## Makes it so that when advancing stages, it uses movement opportunities rather than just going raw timer

enum ChargeType {
	TIMER, ## The charge is started when the timer starts ticking down and ends when the timer reaches 0
	AUDIO_STREAM, ## The charge is started when the audio stream is played and ended when the audio stream ends
	INSTANT ## The charge happens and ends as soon as the total_stages is complete
}

enum FreezeCondition {
	NEVER, ## The charge timer cannot be manipulated
	WHEN_CAMERA_VIEWED, ## The charge timer is manipulated when the current camera this character is on is viewed
	WHEN_CAMERAS_ACTIVE, ## The charge timer is manipulated when the cameras are inactive
	WHEN_CAMERAS_INACTIVE ## The charge timer is manipulated when the cameras are active
}

## Only active when freeze_condition is WHEN_CAMERA_VIEWED or WHEN_CAMERAS_ACTIVE
enum FreezeEffect {
	FROZEN, ## Disables the charge timer when freeze_condition is met
	SLOWED ## Slows down the charge timer based on the slow_multiplier when freeze_condition
} 


signal stage_changed(current_stage: int)
signal charge_started()
signal charge_ended()

func _process(delta: float) -> void:
	if state == CharacterState.INACTIVE:
		return
	
	super(delta)
	
	if is_charging:
		tick_charge(delta)
	else:
		tick_stage(delta)

func tick_stage(delta: float) -> void:
	stage_timer += get_effective_delta(delta)
	
	if stage_timer >= stage_timer_duration:
		stage_timer = 0.0
		if stage >= total_stages:
			begin_charge()
		elif use_movement_opportunity:
			if movement_opportunity():
				increment_stage()
		else:
			increment_stage()

func tick_charge(delta: float) -> void:
	if charge_type != ChargeType.TIMER:
		return
	charge_timer += delta
	if charge_timer >= charge_duration:
		charge_timer = 0.0
		on_charge_end()

func attempt_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	pass

func begin_charge():
	is_charging = true
	movement_succeeded
	charge_started.emit()
	charge()

func charge() -> void:
	match charge_type:
		ChargeType.INSTANT:
			on_charge_end()
		ChargeType.TIMER:
			pass
		ChargeType.AUDIO_STREAM:
			play_charge_audio()

func on_charge_end():
	is_charging = false
	charge_ended.emit()
	attempt_attack(target_door)

func play_charge_audio() -> void:
	pass

func increment_stage() -> void:
	stage += 1

func decrement_stage() -> void:
	stage -= 1

func get_effective_delta(delta: float) -> float:
	match freeze_condition:
		FreezeCondition.NEVER:
			return delta
		
		FreezeCondition.WHEN_CAMERA_VIEWED:
			return apply_freeze(delta, currently_watched)
		
		FreezeCondition.WHEN_CAMERAS_ACTIVE:
			return apply_freeze(delta, OfficeNightWatchManager.instance.cameras_active)
		
		FreezeCondition.WHEN_CAMERAS_INACTIVE:
			return apply_freeze(delta, not OfficeNightWatchManager.instance.cameras_active)
	
	return delta

func apply_freeze(delta: float, condition_met: bool) -> float:
	if condition_met:
		is_lingering = false
		linger_timer = 0.0
		return get_frozen_delta(delta)
	
	if linger_freeze_time and is_lingering:
		linger_timer -= delta
		if linger_timer > 0.0:
			return get_frozen_delta(delta)
		is_lingering = false
	
	return delta

func get_frozen_delta(delta: float) -> float:
	match freeze_effect:
		FreezeEffect.FROZEN: return 0.0
		FreezeEffect.SLOWED: return delta * slow_multiplier
		_: return delta

func reset() -> void:
	super()
	stage = 0
	stage_timer = 0.0
	is_charging = false
	charge_timer = 0.0
	state = CharacterState.ACTIVE

func get_current_location() -> GameConstants.CameraID:
	if is_charging:
		return GameConstants.CameraID.NONE
	return current_location

func get_camera_state() -> String:
	if is_charging:
		return "charging"
	return "stage_" + str(stage)


func on_watched_changed(watched: bool) -> void:
	if not linger_freeze_time:
		return
	if not watched:
		is_lingering = true
		linger_timer = randf_range(linger_min, linger_max)
