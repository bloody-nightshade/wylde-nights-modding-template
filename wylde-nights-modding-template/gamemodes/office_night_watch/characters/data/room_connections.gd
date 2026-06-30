class_name RoomConnections extends Resource
## [RoomConnections] is the list of moves available from a single room. A [RoomGraph] holds one [RoomConnections] per room, keyed by [member GameConstants.CameraID].

## Every move that can be made from this room. Each entry's [member RoomConnection.weight] sets how likely it is relative to the others in this list.
@export var room_connections: Array[RoomConnection]
