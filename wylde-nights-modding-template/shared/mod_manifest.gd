class_name ModManifest extends Resource
## The resource that dictates the metadata of a mod

## The ID of this mod
## This is used for Namespaces, whilst technically not required, it would be nice if you used only lowercases, no spaces and only _ - . for your symbols.
@export var mod_id: String = ""
## The display name of the mod.
@export var mod_name: String = ""
## The ID of you, the author, the creator.
## This is used for Namespaces, whilst technically not required, it would be nice if you used only lowercases, no spaces and only _ - . for your symbols.
@export var author_id: String = ""
## The display name of you, the author, the creator
@export var author: String = ""
## The version of the mod
@export var version: String = "1.0"
## The description of your mod and what functionality it has. This will show up in the mod menu in the main menu desktop.
@export_multiline var description: String = ""
