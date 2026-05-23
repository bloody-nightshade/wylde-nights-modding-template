class_name PathCharacter extends BaseCharacter

@export var path: Array[GameConstants.CameraID] = []
var current_path_index: int = 0

var movement_timer_elapsed: float = 0.0
@export var movement_timer_duration: float = 3.0

func _ready() -> void:
	super()
	
	current_location = path[current_path_index]

func _process(delta: float) -> void:
	if state == CharacterState.INACTIVE:
		return
	
	super(delta)
	
	movement_timer_elapsed += delta
	if movement_timer_elapsed >= get_movement_interval():
		movement_timer_elapsed -= get_movement_interval()
		
		attempt_movement()

func get_movement_interval() -> float:
	return movement_timer_duration

func movement() -> void:
	super()
	
	if path.is_empty():
		push_warning(character_id + " has no path defined")
		return
	
	var previous_location = get_current_location()
	
	if check_if_at_final_location():
		attempt_attack(GameConstants.parse_office_location(path[current_path_index]))
		return
	
	current_path_index += 1
	current_location = path[current_path_index]
	movement_succeeded.emit(previous_location, get_current_location())
	

func get_current_location() -> GameConstants.CameraID:
	if path.is_empty():
		return GameConstants.CameraID.CAM_4
	
	return path[current_path_index]

func check_if_at_final_location() -> bool:
	return current_path_index >= path.size() - 1

func reset() -> void:
	super()
	
	var previous_location = get_current_location()
	current_path_index = 0
	current_location = path[current_path_index]
	movement_succeeded.emit(previous_location, get_current_location())
	state = CharacterState.ACTIVE
