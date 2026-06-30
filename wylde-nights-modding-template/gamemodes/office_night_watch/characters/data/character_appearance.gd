class_name CharacterAppearance extends Resource
## [CharacterAppearance] is the base wrapper that lets a sprite and an animated sprite be used interchangeably wherever an appearance is expected.[br]
## It defines the shared interactivity fields and the [method get_node]/[method has_click_region] contract that the subclasses fulfil. [br][br]
## Don't use [CharacterAppearance] directly. Its [method get_node] returns null, so a bare instance renders nothing. Always use [SpriteAppearance] or [AnimatedAppearance] - both inherit every property and method on this page.

@export_group("Interactivity")
## Whether this appearance can be clicked.
@export var interactable: bool = false
## The clickable area of the appearance. An empty rect means "no region".
@export var click_region: Rect2 = Rect2()

## Builds and returns the [Node2D] used to display this appearance.[br]
## On the base class this returns null - it exists only to be overridden. The subclasses return a real node:[br]
## - [SpriteAppearance] returns a [Sprite2D].[br]
## - [AnimatedAppearance] returns an [AnimatedSprite2D].
func get_node() -> Node2D:
	return null

## Returns [code]true[/code] when [member click_region] has both a non-zero width and a non-zero height, i.e. when an actual clickable area has been set.
func has_click_region() -> bool:
	return click_region.size.x > 0.0 and click_region.size.y > 0.0
