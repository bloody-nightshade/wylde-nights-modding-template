class_name GameConstants
## `GameConstants` is a static utility class that holds core enums for various aspects of the game with states, events and helper functions. [br]
## Since each enums and functions are `static`, it allows you to use it generally everywhere


## Defines every camera, the office/boiler room, both doors and nowhere.[br]
## [code]CAM_1[/code]–[code]CAM_8[/code] are real cameras shown within the camera system.
enum CameraID {
	CAM_1, ## Connected to CAM_2 and CAM_4
	CAM_2, ## Connected to CAM_1 and CAM_3
	CAM_3, ## Connected to LEFT_DOOR, CAM_2 and CAM_5
	CAM_4, ## Connected to CAM_1, CAM_5 and CAM_6
	CAM_5, ## Connected to CAM_4, CAM_3 and CAM_8
	CAM_6, ## Connected to CAM_4 and CAM_7
	CAM_7, ## Connected to CAM_6 and CAM_8
	CAM_8, ## Connected to RIGHT_DOOR, CAM_5 and CAM_7
	LEFT_DOOR, ## Character is at your left door. Mainly for sprite handling - can also represent a character in the boiler room darkness (e.g. Luci's / Starburst's eyes in the doorway).
	RIGHT_DOOR, ## Character is at your right door. Mainly for sprite handling - can also represent a character in the boiler room darkness (e.g. Luci's / Starburst's eyes in the doorway).
	OFFICE, ## Used for office-type enemies or enemies that show up within the office itself.
	NONE, ## Nowhere. Nothing exists here, nothing depends on this - even more useless than OFFICE.
}

## Translates door [enum CameraID] values into the camera they map to, so sprites resolve correctly.[br]
## [param cam_id] is the ID to translate.[br]
## Returns:[br]
## [code]LEFT_DOOR[/code] -> [code]CAM_3[/code][br]
## [code]RIGHT_DOOR[/code] -> [code]CAM_8[/code][br]
## Any other value is returned unchanged.
static func parse_door_to_cam_id(cam_id: GameConstants.CameraID) -> GameConstants.CameraID:
	match cam_id:
		GameConstants.CameraID.LEFT_DOOR:
			return GameConstants.CameraID.CAM_3
		GameConstants.CameraID.RIGHT_DOOR:
			return GameConstants.CameraID.CAM_8
	
	return cam_id

## The position of a character relative to the office view.[br]
## For office-based characters [code]MIDDLE[/code] should generally be used - see [code]BaseCharacter.get_office_state()[/code] and the states in [code]CharacterData.office_appearances[/code].
enum OfficePosition {
	NONE, ## No position.
	LEFT_DOOR, ## At the left door.
	RIGHT_DOOR, ## At the right door.
	MIDDLE, ## Middle of the office.
}

## Translates a [enum CameraID] into an [enum OfficePosition].[br]
## [param cam_id] is the camera/location to translate.[br]
## Returns: [code]LEFT_DOOR[/code] -> [code]LEFT_DOOR[/code], [code]RIGHT_DOOR[/code] -> [code]RIGHT_DOOR[/code], [code]OFFICE[/code] -> [code]MIDDLE[/code]; anything else -> [code]NONE[/code].[br]
## [b]Warning:[/b] any actual camera ([code]CAM_1[/code]–[code]CAM_8[/code]) returns [code]NONE[/code], [b]not[/b] a position. Only the doors and [code]OFFICE[/code] map to a real [enum OfficePosition].
static func parse_cam_id_to_office_pos(cam_id: GameConstants.CameraID) -> OfficePosition:
	match cam_id:
		GameConstants.CameraID.LEFT_DOOR:
			return GameConstants.OfficePosition.LEFT_DOOR
		GameConstants.CameraID.RIGHT_DOOR:
			return GameConstants.OfficePosition.RIGHT_DOOR
		GameConstants.CameraID.OFFICE:
			return GameConstants.OfficePosition.MIDDLE
	
	return OfficePosition.NONE

## Translates an [enum OfficePosition] into a [enum CameraID].[br]
## [param pos] is the position to translate.[br]
## Returns: [code]LEFT_DOOR[/code] -> [code]CAM_3[/code], [code]RIGHT_DOOR[/code] -> [code]CAM_8[/code]; anything else -> [code]NONE[/code].[br]
## [b]Warning:[/b] [code]MIDDLE[/code] returns [code]NONE[/code], not [code]OFFICE[/code] - this isn't a perfect round-trip of [method parse_cam_id_to_office_pos]. Only the two door positions map back.
static func parse_office_pos_to_cam_id(pos: GameConstants.OfficePosition) -> GameConstants.CameraID:
	match pos:
		GameConstants.OfficePosition.LEFT_DOOR:
			return GameConstants.CameraID.CAM_3
		GameConstants.OfficePosition.RIGHT_DOOR:
			return GameConstants.CameraID.CAM_8
		_:
			return GameConstants.CameraID.NONE

## Open/closed state of a door.
enum DoorState {
	OPEN, ## Door is open.
	CLOSED, ## Door is closed.
}

## Events broadcast to the stream system.[br]
## Entries that "accept a custom tag" take an extra string argument elsewhere in the API to disambiguate (e.g. which character moved).
enum StreamEvent {
	MOVEMENT_INTO_CAM, ## Character moves into the current camera. Accepts a custom tag: a namespaced character ID e.g. "wylde_nights:wylde" or "mr_godot:nightshade:mr_godot".
	MOVEMENT_OUT_OF_CAM, ## Character moves out of the current camera. Accepts a custom tag: a namespaced character ID e.g. "wylde_nights:wylde" or "mr_godot:nightshade:mr_godot".
	MOVEMENT_NOT_SEEN, ## Character moves but is not seen at all. Accepts a custom tag: a namespaced character ID e.g. "wylde_nights:wylde" or "mr_godot:nightshade:mr_godot".
	CAM_TOGGLED, ## Camera toggled.
	CAM_OPENED, ## Camera opened.
	CAM_CLOSED, ## Camera closed.
	CAM_SWITCH, ## Camera switched. Accepts a custom tag: a camera ID e.g. "CAM_1".
	DOOR_TOGGLED, ## Any door toggled.
	DOOR_CLOSED, ## Any door closed.
	DOOR_OPENED, ## Any door opened.
	LEFT_DOOR_TOGGLED, ## Left door toggled.
	LEFT_DOOR_CLOSED, ## Left door closed.
	LEFT_DOOR_OPENED, ## Left door opened.
	RIGHT_DOOR_TOGGLED, ## Right door toggled.
	RIGHT_DOOR_CLOSED, ## Right door closed.
	RIGHT_DOOR_OPENED, ## Right door opened.
	CHARACTER_BLOCKED, ## Character blocked. Accepts a custom tag: a namespaced character ID e.g. "wylde_nights:wylde" or "mr_godot:nightshade:mr_godot".
}

## Tries to look up a [enum StreamEvent] by its name. The lookup is [b]case-insensitive[/b], so "door_toggled" is the same as "DOOR_TOGGLED".[br]
## [param event] is the name of the event (matches an enum key).[br]
## Returns the matching event, or [code]MOVEMENT_INTO_CAM[/code] if the string doesn't match any key.[br]
## [b]Warning:[/b] an unrecognised or misspelled string returns [code]MOVEMENT_INTO_CAM[/code] rather than failing. Validate your strings, else it could lead to chat messages firing for improper events.
static func parse_stream_event(event: String) -> GameConstants.StreamEvent:
	var key: String = event.to_upper()
	if GameConstants.StreamEvent.has(key):
		return GameConstants.StreamEvent[key]
	
	return GameConstants.StreamEvent.MOVEMENT_INTO_CAM

## The current mood of the stream, driven by what's happening to the player.
enum StreamMood {
	ANY, ## Applies to anything no matter the mood.
	BORED, ## Nothing is happening.
	HYPE, ## Things are picking up.
	VERYHYPE, ## The player's actions and survival have led the stream to be hyped.
	SCARED, ## Things are getting tense.
	VERYSCARED, ## The player's life is at risk.
}

## Tries to look up a [enum StreamMood] by its name. The lookup is [b]case-insensitive[/b], so "bored" is the same as "BORED".[br]
## [param mood] is the name of the mood (matches an enum key).[br]
## Returns the matching mood, or [code]ANY[/code] if the string doesn't match any key.[br]
## [b]Warning:[/b] an unrecognised or misspelled string returns [code]ANY[/code] rather than failing. Validate your strings, else it could lead to chat messages firing for improper moods.
static func parse_stream_mood(mood: String) -> GameConstants.StreamMood:
	var key: String = mood.to_upper()
	if GameConstants.StreamMood.has(key):
		return GameConstants.StreamMood[key]
	
	return GameConstants.StreamMood.ANY

## A coarse left/right/center direction. Mainly used for handling subtitles.
enum Direction {
	LEFT, ## Left.
	RIGHT, ## Right.
	CENTER, ## Center.
}

## Translates a [enum CameraID] to a [enum Direction].[br]
## [param cam] is the camera/location to classify.[br]
## Returns: [br]
## - [code]CAM_1[/code], [code]CAM_2[/code], [code]CAM_3[/code], [code]LEFT_DOOR[/code] -> [code]LEFT[/code][br]
## - [code]CAM_6[/code], [code]CAM_7[/code], [code]CAM_8[/code], [code]RIGHT_DOOR[/code] -> [code]RIGHT[/code][br]
## - Everything else -> [code]CENTER[/code].
static func parse_cam_id_to_direction(cam: GameConstants.CameraID) -> GameConstants.Direction:
	var left = [GameConstants.CameraID.CAM_1, GameConstants.CameraID.CAM_2, GameConstants.CameraID.CAM_3, GameConstants.CameraID.LEFT_DOOR]
	var right = [GameConstants.CameraID.CAM_6, GameConstants.CameraID.CAM_7, GameConstants.CameraID.CAM_8, GameConstants.CameraID.RIGHT_DOOR]
	var _center = [GameConstants.CameraID.CAM_4, GameConstants.CameraID.CAM_5]
	
	if cam in left:
		return Direction.LEFT
	elif cam in right:
		return Direction.RIGHT
	else:
		return Direction.CENTER
	

## Translates an [enum OfficePosition] to a [enum Direction].[br]
## [param pos] is the position to classify.[br]
## Returns:[br]
## - [code]LEFT_DOOR[/code] -> [code]LEFT[/code] 
## - [code]RIGHT_DOOR[/code] -> [code]RIGHT[/code]
## - Everything else -> [code]CENTER[/code].
static func parse_office_pos_to_direction(pos: GameConstants.OfficePosition) -> GameConstants.Direction:
	var left = [GameConstants.OfficePosition.LEFT_DOOR]
	var right = [GameConstants.OfficePosition.RIGHT_DOOR]
	
	if pos in left:
		return Direction.LEFT
	elif pos in right:
		return Direction.RIGHT
	else:
		return Direction.CENTER
		
		parse_direction_to_string

## Returns a [enum Direction] as a [String], e.g. [code]Direction.LEFT[/code] -> "LEFT".[br]
## [param dir] is the direction to stringify.[br]
## The main use case is subtitles while the player has the "Directions in subtitles" accessibility option enabled.
static func parse_direction_to_string(dir: GameConstants.Direction) -> String:
	return GameConstants.Direction.keys()[dir]
