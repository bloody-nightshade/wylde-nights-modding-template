class_name RngPathCharacter extends BaseCharacter

@export var room_graph: RoomGraph
@export var movement_cooldown_min: float = 5.0
@export var movement_cooldown_max: float = 5.0

var movement_cooldown: float = 0.0
var movement_timer: float = 0.0

func _ready() -> void:
	super()
	movement_cooldown = get_movement_cooldown()

func _process(delta: float) -> void:
	super(delta)
	
	movement_timer += delta
	if movement_timer >= movement_cooldown:
		movement_timer -= movement_cooldown
		movement_cooldown = get_movement_cooldown()
		attempt_movement()

func movement() -> void:
	super()
	
	if is_currently_at_door(current_location):
		attempt_attack(GameConstants.parse_office_location(current_location))
		return
	
	if not room_graph.graph.has(current_location):
		print("no location")
		return
	
	var previous_location = current_location
	var connections: RoomConnections = room_graph.graph[current_location]
	current_location = pick_weighted_random(connections)
	
	movement_succeeded.emit(previous_location, current_location)

func pick_weighted_random(connections: RoomConnections) -> GameConstants.CameraID:
	var total_weight: int = 0
	for connection in connections.room_connections:
		total_weight += connection.weight
	
	var roll = randi_range(0, total_weight - 1)
	var cumulative_weight: int = 0
	for connection in connections.room_connections:
		cumulative_weight += connection.weight
		if roll < cumulative_weight:
			return connection.destination
	
	return connections.room_connections[-1].destination

func is_currently_at_door(cam_id: GameConstants.CameraID) -> bool:
	return cam_id in [GameConstants.CameraID.LEFT_DOOR, GameConstants.CameraID.RIGHT_DOOR]

func get_movement_cooldown() -> float:
	return randf_range(movement_cooldown_min, movement_cooldown_max)

func reset() -> void:
	super()
	movement_timer = 0.0
	state = CharacterState.ACTIVE
	
	var old_position = current_location
	current_location = GameConstants.CameraID.CAM_4
	
	movement_succeeded.emit(old_position, current_location)
