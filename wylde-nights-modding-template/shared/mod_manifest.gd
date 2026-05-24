class_name ModManifest extends Resource
## DONT EDIT THIS FILE PLEASE.
## IF YOU WANT TO CREATE A MOD MANIFEST CLICK ON NEW RESOURCE AND FIND THE MOD MANIFEST RESOURCE AND FILL THAT IN.

@export var mod_id: String = "" ## This is your Mod ID, this must be unique else it will conflict with other mods and not get loaded. The suggested format for this would be something like `your-pseudonym:mod-id`
@export var author: String = "" ## Your display name/pseudonym
@export var version: String = "1.0" ## Your Mod version
@export var mod_name: String = "" ## Display name for your mod
@export_multiline var description: String = "" ## The thing that describes your mod
