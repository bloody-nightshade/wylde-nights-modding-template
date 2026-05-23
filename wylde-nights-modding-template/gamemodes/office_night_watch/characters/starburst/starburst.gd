class_name Starburst extends PathCharacter

@onready var door_bang: AudioStreamPlayer2D = $DoorBangingAudio

func _ready() -> void:
	super()
	
	OfficeNightWatchManager.instance.door_state_changed.connect(do_failed_attack_early)

func attempt_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	if OfficeNightWatchManager.instance.is_door_open(GameConstants.OfficePosition.RIGHT_DOOR):
		attack(office_position, "default")
	else:
		failed_attack(office_position)

func movement() -> void:
	super()
	
	do_failed_attack_early(GameConstants.OfficePosition.RIGHT_DOOR, GameConstants.DoorState.OPEN)

func do_failed_attack_early(side: GameConstants.OfficePosition, _state: GameConstants.DoorState) -> void:
	if check_if_at_final_location() and OfficeNightWatchManager.instance.is_door_closed(GameConstants.OfficePosition.RIGHT_DOOR):
		attempt_attack(side)

func failed_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	door_bang.play()
