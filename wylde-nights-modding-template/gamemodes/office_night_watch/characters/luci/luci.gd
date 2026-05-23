class_name Luci extends RngPathCharacter

@onready var movement_audio: AudioStreamPlayer2D = $MovementAudio
@onready var door_banging_audio: AudioStreamPlayer2D = $DoorBangingAudio

func movement() -> void:
	super()
	
	movement_audio.play()

func attempt_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	if OfficeNightWatchManager.instance.is_door_open(office_position):
		attack(office_position, "default")
	else:
		failed_attack(office_position)

func failed_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	door_banging_audio.play()
