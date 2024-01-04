extends Resource
class_name Block

@export var texture: Texture2D
@export var topTexture: Texture2D
@export var bottomTexture: Texture2D

# var textures: Array[Texture2D] = [texture, topTexture, bottomTexture]
# var textures: Array[Texture2D]
# var textures: Array[bool] = [texture == null, topTexture == null, bottomTexture == null]
# var textures: Array[bool]
# func _ready():
#     textures = [texture == null, topTexture == null, bottomTexture == null]

func textures() -> Array[Texture2D]:
    return [texture, topTexture, bottomTexture]