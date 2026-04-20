class_name AnimatedAppearance extends CharacterAppearance

@export var sprite_frames: SpriteFrames
@export var autoplay: String = "default"

func get_node() -> Node2D:
	var animated_sprite = AnimatedSprite2D.new()
	
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play(autoplay)
	
	return animated_sprite
