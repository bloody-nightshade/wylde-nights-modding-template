class_name Appearances extends Resource
## [Appearances] is the container that holds every visual state a character can be in for a single location, keyed by name.[br]
##
## It's the value type used by the [member camera_appearances] and [member office_appearances] values on [CharacterData]: each camera or office position maps to one [Appearances], and that [Appearances] in turn maps state names to the art shown in each state.[br]
## Think of this as "all the ways this character can look while it's in this one spot."

## Maps a state name (e.g. [code]"idle"[/code]) to the appearance shown while the character is in that state.
@export var appearances: Dictionary[String, CharacterAppearance]
