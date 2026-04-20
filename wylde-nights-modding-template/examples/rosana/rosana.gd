class_name Rosana extends BaseCharacter

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var advert_spawn_min: float = 0.0
@export var advert_spawn_max: float = 0.0
var spawn_timer: float = 0.0
var next_spawn_time: float = 0.0

const TITLES: Array[String] = [
	"HOT MILFS IN YOUR AREA!!",
	"NO CC REQUIRED",
]

const ADVERTS: Array[CompressedTexture2D] = [
	preload("res://examples/rosana/sprites/icon.svg")
]

const ROSANA_ADVERT = preload("res://examples/rosana/rosana_advert.tscn")

var active_adverts: Array[RosanaAdvert] = []

func _ready() -> void:
	super()
	next_spawn_time = get_next_spawn_time()

func _process(delta: float) -> void:
	if state == CharacterState.INACTIVE:
		return
	
	super(delta)
	
	spawn_timer += delta
	if spawn_timer >= next_spawn_time:
		spawn_timer -= next_spawn_time
		next_spawn_time = get_next_spawn_time()
		spawn_advert()

func get_next_spawn_time() -> float:
	return randf_range(advert_spawn_min - difficulty, advert_spawn_max - difficulty)

func spawn_advert() -> void:
	
	var advert: RosanaAdvert = ROSANA_ADVERT.instantiate()
	
	canvas_layer.add_child(advert)
	
	advert.set_image(ADVERTS.pick_random())
	advert.set_title(TITLES.pick_random())
	
	advert.position_randomly()
	
	active_adverts.append(advert)
	
	

func on_advert_closed(advert: RosanaAdvert) -> void:
	active_adverts.erase(advert)

func get_current_location() -> GameConstants.CameraID:
	return GameConstants.CameraID.OFFICE

func reset() -> void:
	super()
