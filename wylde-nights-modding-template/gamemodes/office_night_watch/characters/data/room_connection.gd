class_name RoomConnection extends Resource
## [RoomConnection] is a single weighted move from one room to another. A list of these (held by a [RoomConnections]) describes everywhere a character can go from a given room.

## The room this move leads to.
@export var destination: GameConstants.CameraID
## How likely this move is, relative to the other connections in the same [RoomConnections]. Bigger number means more likely.
@export var weight: int = 1
