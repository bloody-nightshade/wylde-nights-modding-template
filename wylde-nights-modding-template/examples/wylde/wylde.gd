class_name Wylde extends FoxyLikeCharacter

@onready var charge_audio: AudioStreamPlayer2D = $ChargeAudio
@onready var room_swap_audio: AudioStreamPlayer2D = $RoomSwapAudio
@onready var door_banging_audio: AudioStreamPlayer2D = $DoorBangingAudio
@export var room_swap_cooldown: float = 0.0
var room_swap_timer: float = 0.0



@export var possible_locations: Array[GameConstants.CameraID] = [
	GameConstants.CameraID.CAM_2,
	GameConstants.CameraID.CAM_7,
]

signal room_swapped()

func _ready() -> void:
	super()
	current_location = possible_locations.pick_random()
	set_target_door()
	
	charge_audio.finished.connect(on_charge_end)
	set_room_swap_timer()

func _process(delta: float) -> void:
	
	if state == CharacterState.INACTIVE:
		return
	
	super(delta)
	
	if not is_charging:
		room_swap_timer += delta
	
	if room_swap_timer >= room_swap_cooldown:
		room_swap_timer -= room_swap_cooldown
		swap_rooms()
		set_room_swap_timer()

func play_charge_audio() -> void:
	# Cat Smokey Meow 1 by redjamie7 -- https://freesound.org/s/729031/ -- License: Attribution 4.0 
	# Remember to add to credits please for the love of god
	charge_audio.play() 

func attempt_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	if OfficeNightWatchManager.instance.is_door_closed(office_position):
		failed_attack(office_position)
	else:
		attack(office_position, "default")

func failed_attack(office_position: GameConstants.OfficePosition) -> void:
	super(office_position)
	
	door_banging_audio.play()

func swap_rooms() -> void:
	var room = possible_locations.pick_random()
	set_room_swap_timer()
	
	if room != get_current_location():
		var previous_location = current_location
		current_location = room
		
		movement_succeeded.emit(previous_location, get_current_location())
		room_swapped.emit()
		
		room_swap_audio.play()
		set_target_door()

func set_target_door():
	if get_current_location() in [GameConstants.CameraID.CAM_1, GameConstants.CameraID.CAM_2, GameConstants.CameraID.CAM_3]:
		target_door = GameConstants.OfficePosition.LEFT_DOOR
	elif get_current_location() in [GameConstants.CameraID.CAM_6, GameConstants.CameraID.CAM_7, GameConstants.CameraID.CAM_8]:
		target_door = GameConstants.OfficePosition.RIGHT_DOOR

func set_room_swap_timer():
	room_swap_cooldown = randi_range(30 - difficulty, 60 - difficulty)

var timer: float = 0.0

func test(delta: float):
	
	var cooldown: float = 5.0
	
	timer += delta
	if timer >= cooldown:
		timer -= cooldown
		# Or you can just do this instead:
		# timer = 0
		
		# And then just run whatever else code you want to run when the timer has ended
