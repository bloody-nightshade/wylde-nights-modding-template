class_name SpriteAppearance extends CharacterAppearance
## [SpriteAppearance] extends [CharacterAppearance] and is the appearance type for a single static image. Use it for any state that doesn't animate.

## The image to display.
@export var texture: Texture2D

## Returns a new [Sprite2D] whose texture is set to [member texture]. This overrides the base [CharacterAppearance] [method get_node], which returns [code]null[/code].
func get_node() -> Node2D:
	var sprite = Sprite2D.new()
	sprite.texture = texture
	return sprite
