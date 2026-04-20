class_name RosanaAdvert extends PanelContainer

@onready var title_text: Label = $AdvertMargins/AdvertAlignment/TitleBar/TitleMargins/TitleAlignment/TitleText
@onready var advert_content: TextureRect = $AdvertMargins/AdvertAlignment/AdvertBody/AdvertContent
@onready var button: Button = $AdvertMargins/AdvertAlignment/TitleBar/TitleMargins/TitleAlignment/CloseButton/Button

signal advert_closed(advert: RosanaAdvert)

func _ready() -> void:
	button.pressed.connect(on_close_button_clicked)

func set_title(text: String) -> void:
	title_text.text = text

func set_image(sprite: CompressedTexture2D) -> void:
	advert_content.texture = sprite

func on_close_button_clicked() -> void:
	advert_closed.emit(self)
	queue_free()

func position_randomly() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	position = Vector2(
		randf_range(0, viewport_size.x - size.x),
		randf_range(0, viewport_size.y - size.y)  # 80 for taskbar
	)
