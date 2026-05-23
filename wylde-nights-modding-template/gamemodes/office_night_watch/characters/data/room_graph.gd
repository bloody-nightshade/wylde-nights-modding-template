@tool class_name RoomGraph extends Resource

## There is a "Populate Defaults" button that should populate this dictionary with defaults to give you a framework for what to work with, if you wish, you can use this as is.
## As is, it will generally take this character closer to the player's location most of the time.
## The weights used are "Bigger number means more likely"
@export var graph: Dictionary[GameConstants.CameraID, RoomConnections]

@export_tool_button("Populate Defaults") var populate_defaults_button = populate_data

func populate_data():
	if graph.is_empty():
		var excluded_cameras = [GameConstants.CameraID.LEFT_DOOR, GameConstants.CameraID.RIGHT_DOOR, GameConstants.CameraID.OFFICE]
		for cam_id in GameConstants.CameraID.values():
			if cam_id not in excluded_cameras:
				graph[cam_id] = get_default_connections(cam_id)
	notify_property_list_changed()

func get_default_connections(cam_id: GameConstants.CameraID) -> RoomConnections:
	var connections = RoomConnections.new()
	match cam_id:
		GameConstants.CameraID.CAM_1:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_2, 8))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_4, 2))
		GameConstants.CameraID.CAM_2:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_3, 8))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_1, 2))
		GameConstants.CameraID.CAM_3:
			connections.room_connections.append(make_connection(GameConstants.CameraID.LEFT_DOOR, 1))
		GameConstants.CameraID.CAM_4:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_1, 3))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_5, 4))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_6, 3))
		GameConstants.CameraID.CAM_5:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_3, 5))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_8, 5))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_4, 1))
		GameConstants.CameraID.CAM_6:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_7, 8))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_4, 2))
		GameConstants.CameraID.CAM_7:
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_8, 8))
			connections.room_connections.append(make_connection(GameConstants.CameraID.CAM_6, 2))
		GameConstants.CameraID.CAM_8:
			connections.room_connections.append(make_connection(GameConstants.CameraID.RIGHT_DOOR, 1))
		_:
			pass
	return connections

func make_connection(destination: GameConstants.CameraID, weight: int) -> RoomConnection:
	var connection = RoomConnection.new()
	connection.destination = destination
	connection.weight = weight
	return connection
