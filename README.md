# wylde-nights-modding-template

This is a modding template to help with creating custom characters for Wylde Nights.

---

## Requirements

- [Godot 4.4.1](https://godotengine.org/download/archive/4.4.1-stable/)
- A copy of [Wylde Nights](https://store.steampowered.com/app/2137780)

## Getting Started

1. Create a new repo using this template & open it in Godot
2. Duplicate or rename the `mods/characters/template_character` to your own character

## Exporting Your Character

1. Go to `Projects` -> `Export` and select the Wylde Nights Mod preset
2. Click `Export PCK/ZIP...` and name the file whatever you want. Make sure it has the .pck file extention
3. Place the mod pck file into the `user://mods/` dir

`user://`'s file dir location depends on Operating System:
| OS | Path |
|---|---|
| Windows | `%APPDATA%\Godot\app_userdata\Wylde Nights` |
| Linux | `~/.local/share/godot/app_userdata/"Wylde Nights"` |

---

## Contributing

Contributions of all kinds are welcome, this includes bug fixes, new features and improvements to the documentation

Please do read the contributions guide: **[CONTRIBUTING.md](CONTRIBUTING.md)**

---

## License
**wylde-nights-modding-template** is licensed under [MIT License](LICENSE)