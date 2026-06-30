@tool class_name CharacterData extends Resource
## Character Data


## The ID of the character.
## This is used for Namespaces, whilst technically not required, it would be nice if you used only lowercases, no spaces and only _ - . for your symbols.
@export var character_id: String = ""
## The display name for your character
@export var character_display_name: String = ""

## This is what gets instantiated when they're loaded into the game.
## The scene is what runs all of the logic for your character so like... This is super duper important lol
@export var scene: PackedScene

## These allow you to set the difficulties for your character for Nights 1 to 5, keep everything at 0 if you don't want them to appear in the main game.
## The game will error out if it does not at least 5 values here. Any additional values won't crash the game but it wont get used either.
@export var default_difficulties: Array[int] = [0, 0, 0, 0, 0]

@export_group("Visual Apperances")
## Each sprite or sprite in a spritesheet should be 2560 x 1080 so that it can be properly aligned with the player's viewable area in the cameras
@export var camera_appearances: Dictionary[GameConstants.CameraID, Appearances]
@export_subgroup("Init Cameras Buttons", "populate_cameras_")
@export_tool_button("Initialize Camera Appearances") var populate_cameras_button = populate_camera_appearances
@export_tool_button("Initialize Camera Appearances with Idle keys and Sprite values") var populate_cameras_apperances_with_idle_sprite_appearance_values_button = populate_camera_apperances_with_idle_sprite_appearance_values
@export_tool_button("Initialize Camera Appearances with NSFW/SFW keys and Sprite values") var populate_cameras_apperances_with_nsfw_sfw_sprite_appearance_values_button = populate_camera_apperances_with_nsfw_sfw_sprite_appearance_values
@export_tool_button("Initialize Camera Appearances with Idle keys and Animated values") var populate_cameras_apperances_with_idle_animated_appearance_values_button = populate_camera_apperances_with_idle_animated_appearance_values
@export_tool_button("Initialize Camera Appearances with NSFW/SFW keys and Animated values") var populate_cameras_apperances_with_nsfw_sfw_animated_appearance_values_button = populate_camera_apperances_with_nsfw_sfw_animated_appearance_values

## Each sprite or sprite in a spritesheet should be 2560 x 1080 so that it can be properly aligned with the player's viewable area in the office
@export var office_appearances: Dictionary[GameConstants.OfficePosition, Appearances]
@export_subgroup("Init Office Buttons", "populate_office_")
@export_tool_button("Initialize Office Appearances") var populate_office_button = populate_office_appearances
@export_tool_button("Initialize Office Appearances with Idle keys and Sprite values") var populate_office_apperances_with_idle_sprite_appearance_values_button = populate_camera_apperances_with_idle_sprite_appearance_values
@export_tool_button("Initialize Office Appearances with NSFW/SFW keys and Sprite values") var populate_office_apperances_with_nsfw_sfw_sprite_appearance_values_button = populate_camera_apperances_with_nsfw_sfw_sprite_appearance_values
@export_tool_button("Initialize Office Appearances with Idle keys and Animated values") var populate_office_apperances_with_idle_animated_appearance_values_button = populate_camera_apperances_with_idle_animated_appearance_values
@export_tool_button("Initialize Office Appearances with NSFW/SFW keys and Animated values") var populate_office_apperances_with_nsfw_sfw_animated_appearance_values_button = populate_camera_apperances_with_nsfw_sfw_animated_appearance_values

@export_group("Custom Night", "custom_night_")
## The texture that is used on the custom night screen, the standard here is to use 128x128 for your icons, though anything that is with an aspect ratio of 1:1 will work, anything else is untested and might fuck up the UI.
@export var custom_night_icon: Texture2D
## This is the inactive texture for the custom night icon for when your character has a difficulty of 0. The standard is still 128x128 or anything else that has an aspect ratio of 1:1.
## As for colour palette, you should use transparent and #808080ff to replace the blacks from your coloured custom night icon.
## Personally, I create the unselected icon first, then recolour #808080ff to be #000000ff and then fill in all of the colours since that makes things infinitely easier.
@export var custom_night_unselected: Texture2D
@export_multiline var custom_night_description: String = ""

@export_group("Jumpscare", "jumpscare_")
## Each sprite in the spritesheets should be at least 1080 pixels tall so that it can properly fit within the player's viewable area.
## When the player is jumpscared, their view will be pushed towards the centre. So make sure that most of the jumpscare can be seen within that area.
## The node that handles the jumpscare is relative to the centre of the player's screen.
## You can have multiple animations in your jumpscare_animation, you just need to call the correct animation when you're running attempt_attack() otherwise it will default to "default".
## Not required if they don't actually attack the player.
@export var jumpscare_animation: SpriteFrames
## Audio that is played when a jumpscare happens
## Not required if they don't actually attack the player.
@export var jumpscare_audio: AudioStream

@export_group("Death Screen", "death_screen_")
## Sprite that shows up on the gameover screen, would be preferible if it follows the same style as the vanilla gameover screens but this isnt strictly required.
## Feel free to use a sprite or an animation, just make sure that they are at least 1920 x 1080.
## Not required if they don't actually "kill" the player.
@export var death_screen_sprite: CharacterAppearance
## Hints to give players who die.
## Not required if they don't actually "kill" the player.
@export var death_screen_hints: Array[String] = [""]
## Not required if they don't actually "kill" the player.
@export var death_screen_audio: Dictionary[String, AudioStream]

@export_group("Extras Menu", "extras_")
## This is the icon that will be visible when on the overview part of the extras menu
## I'd suggest just using the custom night icon and viceversa 
@export var extras_icon: Texture2D
## This is what will be visible when theyre selected in the extras menu.
@export var extras_portrait: Texture2D
## Use this space to talk about... anything about your character. For example the characters in the vanilla version of this game will have information about what went into their mechanics.
@export_multiline var extras_description: String = ""
## This is just a place for you to store all of the audio assets that you've used for this character.
## Keep in mind, this is only *intended* to be used in the extras menu, even if its *technically* possible to use during normal gameplay...
@export var extras_audio: Dictionary[String, AudioStream]



func populate_camera_appearances() -> void:
	var excluded = [GameConstants.CameraID.OFFICE, GameConstants.CameraID.NONE]
	for cam_id in GameConstants.CameraID.values():
		if cam_id not in excluded and not camera_appearances.has(cam_id):
			camera_appearances[cam_id] = Appearances.new()
	notify_property_list_changed()

func populate_camera_apperances_with_idle_sprite_appearance_values() -> void:
	populate_camera_appearances()
	for cam_id in camera_appearances:
		var appearance: Appearances = camera_appearances[cam_id]
		appearance.populate_idle_sprite_appearance_values()
	notify_property_list_changed()

func populate_camera_apperances_with_nsfw_sfw_sprite_appearance_values() -> void:
	populate_camera_appearances()
	for cam_id in camera_appearances:
		var appearance: Appearances = camera_appearances[cam_id]
		appearance.populate_nsfw_sfw_sprite_appearance_values()
	notify_property_list_changed()

func populate_camera_apperances_with_idle_animated_appearance_values() -> void:
	populate_camera_appearances()
	for cam_id in camera_appearances:
		var appearance: Appearances = camera_appearances[cam_id]
		appearance.populate_idle_animated_appearance_values()
	notify_property_list_changed()

func populate_camera_apperances_with_nsfw_sfw_animated_appearance_values() -> void:
	populate_camera_appearances()
	for cam_id in camera_appearances:
		var appearance: Appearances = camera_appearances[cam_id]
		appearance.populate_nsfw_sfw_animated_appearance_values()
	notify_property_list_changed()



func populate_office_appearances() -> void:
	var excluded = [GameConstants.OfficePosition.NONE]
	for position in GameConstants.OfficePosition.values():
		if position not in excluded and not office_appearances.has(position):
			office_appearances[position] = Appearances.new()
	notify_property_list_changed()

func populate_office_apperances_with_idle_sprite_appearance_values() -> void:
	populate_camera_appearances()
	for office_pos in office_appearances:
		var appearance: Appearances = office_appearances[office_pos]
		appearance.populate_idle_sprite_appearance_values()
	notify_property_list_changed()

func populate_office_apperances_with_nsfw_sfw_sprite_appearance_values() -> void:
	populate_camera_appearances()
	for office_pos in office_appearances:
		var appearance: Appearances = office_appearances[office_pos]
		appearance.populate_nsfw_sfw_sprite_appearance_values()
	notify_property_list_changed()

func populate_office_apperances_with_idle_animated_appearance_values() -> void:
	populate_camera_appearances()
	for office_pos in office_appearances:
		var appearance: Appearances = office_appearances[office_pos]
		appearance.populate_idle_animated_appearance_values()
	notify_property_list_changed()

func populate_office_apperances_with_nsfw_sfw_animated_appearance_values() -> void:
	populate_camera_appearances()
	for office_pos in office_appearances:
		var appearance: Appearances = office_appearances[office_pos]
		appearance.populate_nsfw_sfw_animated_appearance_values()
	notify_property_list_changed()
