class_name SpriteAppearance extends CharacterAppearance

@export var texture: Texture2D

func get_node() -> Node2D:
	var sprite = Sprite2D.new()
	
	sprite.texture = texture
	
	return sprite
