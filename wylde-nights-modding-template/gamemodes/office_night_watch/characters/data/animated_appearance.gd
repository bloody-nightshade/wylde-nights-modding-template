class_name AnimatedAppearance extends CharacterAppearance
## [AnimatedAppearance] extends [CharacterAppearance] and is the appearance type for an animation driven by a [SpriteFrames] resource. Use it for any state that needs to be animated.[br]

## The animation frames to display.
@export var sprite_frames: SpriteFrames
## Name of the animation (inside [member sprite_frames]) to start playing on creation.
@export var autoplay: String = "default"

## Returns a new [AnimatedSprite2D] whose [member sprite_frames] is set, already playing the animation named by [member autoplay].[br] 
## This overrides the base CharacterAppearance get_node(), which returns [code]null[/code].
func get_node() -> Node2D:
	var animated_sprite = AnimatedSprite2D.new()
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play(autoplay)
	return animated_sprite
