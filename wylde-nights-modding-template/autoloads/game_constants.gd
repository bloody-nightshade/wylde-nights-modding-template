class_name GameConstants extends Node

enum CameraID {
	CAM_1, ## Connected to CAM_2 and CAM_4
	CAM_2, ## Connected to CAM_1 and CAM_3
	CAM_3, ## Connected to LEFT_DOOR, CAM_2 and CAM_5
	CAM_4, ## Connected to CAM_1, CAM_5 and CAM_6
	CAM_5, ## Connected to CAM_4, CAM_3 and CAM_8
	CAM_6, ## Connected to CAM_4 and CAM_7
	CAM_7, ## Connected to CAM_6 and CAM_8
	CAM_8, ## Connected to RIGHT_DOOR, CAM_5 and CAM_7
	LEFT_DOOR, ## This exists to depict if the character is currently at your left door as to give a "stage" before attacking or to do some sprite shenannigans
	RIGHT_DOOR, ## This exists to depict if the character is currently at your right door as to give a "stage" before attacking or to do some sprite shenannigans 
	OFFICE, ## This exists as to describe the failstate in some situations, but there are definitely better ways of describing such a failstate
	NONE, ## Nowhere, nothing exists here, nothing depends on this, even more usless than OFFICE
}

## Translates the Door IDs to Camera IDs to properly fix sprites
static func parse_camera_id(cam_id: GameConstants.CameraID) -> GameConstants.CameraID:
	match cam_id:
		GameConstants.CameraID.LEFT_DOOR:
			return GameConstants.CameraID.CAM_3
		GameConstants.CameraID.RIGHT_DOOR:
			return GameConstants.CameraID.CAM_8
	return cam_id

enum OfficePosition {
	NONE,
	LEFT_DOOR,
	RIGHT_DOOR
}

## Translates CameraID to OfficePosition
static func parse_office_location(cam: GameConstants.CameraID) -> OfficePosition:
	if cam == GameConstants.CameraID.LEFT_DOOR:
		return OfficePosition.LEFT_DOOR
	elif cam == GameConstants.CameraID.RIGHT_DOOR:
		return OfficePosition.RIGHT_DOOR
	
	return OfficePosition.NONE

enum DoorState {
	OPEN,
	CLOSED
}
