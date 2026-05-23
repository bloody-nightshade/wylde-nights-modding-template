@tool class_name CharacterData extends Resource

## The ID of the character, preferibly to ensure no conflicts with any other mod creator you should make your ID something like: "author_id:character_id" or in the case for vanilla characters it would be "nightshade:starburst"
@export var character_id: String = ""
## This is what will show up for the player.
@export var character_display_name: String = ""

## This is your thing isn't it? At least credit yourself for it!! :steamhappy:
@export var author: String = ""

## These allow you to set the difficulties for your character for Nights 1 to 5, keep everything at 0 if you don't want them to appear in the main game.
@export var default_difficulties: Array[int] = [0, 0, 0, 0, 0]
## I'll put something here eventually
@export var scene: PackedScene

## Each sprite or sprite in a spritesheet should be 2560 x 1080 so that it can be properly aligned with the player's viewable area in the cameras
@export var camera_appearances: Dictionary[GameConstants.CameraID, Appearances]
@export_tool_button("Populate Camera Appearances") var populate_cameras_button = populate_camera_appearances
## Each sprite or sprite in a spritesheet should be 2560 x 1080 so that it can be properly aligned with the player's viewable area in the office
## Currently non-functional
@export var office_appearances: Dictionary[GameConstants.OfficePosition, Appearances]
@export_tool_button("Populate Office Appearances") var populate_office_button = populate_office_appearances


## Each sprite in the spritesheets should be at least 1080 pixels tall so that it can properly fit within the player's viewable area.
## When the player is jumpscared, their view will be pushed towards the centre. So make sure that most of the jumpscare can be seen within that area.
## The node that handles the jumpscare is relative to the centre of the player's screen.
## You can have multiple animations in your jumpscare_animation, you just need to call the correct animation when you're running attempt_attack() otherwise it will default to "default".
## Not required if they don't actually attack the player.
@export var jumpscare_animation: SpriteFrames

## This is what will be visible in the extras menu.
@export var extras_portrait: Texture2D
## Use this space to talk about... anything about your character. For example the characters in the vanilla version of this game will have information about what went into their mechanics.
@export_multiline var extras_description: String = ""

## Sprite that shows up on the gameover screen, would be preferible if it follows the same style as the vanilla gameover screens but this isnt strictly required.
## Feel free to use a sprite or an animation, just make sure that they are at least 1920 x 1080.
## Not required if they don't actually "kill" the player.
@export var death_screen_sprite: CharacterAppearance
## Hints to give players who die.
## Not required if they don't actually "kill" the player.
@export var death_screen_hints: Array[String] = [""]

func populate_camera_appearances() -> void:
	for cam_id in GameConstants.CameraID.values():
		if cam_id not in [GameConstants.CameraID.OFFICE, GameConstants.CameraID.NONE] and not camera_appearances.has(cam_id):
			camera_appearances[cam_id] = Appearances.new()
	notify_property_list_changed()

func populate_office_appearances() -> void:
	for position in GameConstants.OfficePosition.values():
		if position not in [GameConstants.OfficePosition.NONE] and not office_appearances.has(position):
			office_appearances[position] = Appearances.new()
	notify_property_list_changed()
