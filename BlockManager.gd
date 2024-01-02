extends Node
class_name BlockManager

@export var air: Block = Block.new()
@export var grass: Block = Block.new()
@export var stone: Block = Block.new()
@export var dirt: Block = Block.new()

var atlasLUT: Dictionary

var gridWidth: int = 4
var gridHeight: int

var blockTextureSize = Vector2i(1024, 1024)
var textureAtlasSize: Vector2

var chunkMaterial = StandardMaterial3D.new()


func _ready():
	var blockTextures = [air, stone, dirt, grass]

	for block in len(blockTextures):
		blockTextures[block] = blockTextures[block].texture

	blockTextures = blockTextures.filter(
		func(texture): return texture != null && blockTextures.count(texture)
	)

	for i in len(blockTextures):
		atlasLUT[blockTextures[i]] = Vector2i(i % gridWidth, floori(i / gridWidth))

	gridHeight = ceili(len(blockTextures) / float(gridWidth))

	var image = Image.create(
		gridWidth * blockTextureSize.x, gridHeight * blockTextureSize.y, false, Image.FORMAT_RGBA8
	)

	for x in gridWidth:
		for y in gridHeight:
			var imageIndex = x + y * gridWidth

			if imageIndex >= len(blockTextures):
				continue

			print(blockTextures[imageIndex])

			var currentImage = blockTextures[imageIndex].get_image()
			currentImage.convert(Image.FORMAT_RGBA8)

			image.blit_rect(
				currentImage,
				Rect2i(Vector2i.ZERO, blockTextureSize),
				Vector2i(x, y) * blockTextureSize
			)

	var textureAtlas = ImageTexture.create_from_image(image)

	chunkMaterial.albedo_texture = textureAtlas
	chunkMaterial.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

	textureAtlasSize = Vector2(gridWidth, gridHeight)

	print(
		"Loaded {textures} images to make a {width} x {height} atlas.".format(
			{"textures": len(blockTextures), "width": gridWidth, "height": gridHeight}
		)
	)


func getTextureAtlasPosition(texture: Texture2D) -> Vector2i:
	if !texture:
		return Vector2i.ZERO
	else:
		return atlasLUT[texture]
