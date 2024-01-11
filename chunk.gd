class_name Chunk
extends StaticBody3D

@export var collider: CollisionShape3D
@export var mesh: MeshInstance3D
# @export var noise: FastNoiseLite

@onready var blockManager = get_node(^"/root/Level/BlockManager")
@onready var chunkManager = get_node(^"/root/Level/ChunkManager")

var dimensions = Vector3i(32, 32, 32)

var vertices = [
	Vector3i(0, 0, 0),  # 0 | left  | bottom | front
	Vector3i(1, 0, 0),  # 1 | right | bottom | front
	Vector3i(0, 1, 0),  # 2 | left  |  top   | front
	Vector3i(1, 1, 0),  # 3 | right |  top   | front
	Vector3i(0, 0, 1),  # 4 | left  | bottom | back
	Vector3i(1, 0, 1),  # 5 | right | bottom | back
	Vector3i(0, 1, 1),  # 6 | left  |  top   | back
	Vector3i(1, 1, 1)  # 7 | right |  top   | back
]

var top: Array[int] = [2, 3, 7, 6]
var bottom: Array[int] = [0, 4, 5, 1]
var left: Array[int] = [6, 4, 0, 2]
var right: Array[int] = [3, 1, 5, 7]
var front: Array[int] = [2, 0, 1, 3]
var back: Array[int] = [7, 5, 4, 6]

var surfaceTool = SurfaceTool.new()

var blocks: Dictionary

var chunkPosition: Vector2i


func _ready():
	setChunkPosition(Vector2i(floori(global_position.x / dimensions.x), floori(global_position.z / dimensions.z)))

	generate()
	update()


## Generate the [member mesh] and [member collider]
func update():
	surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			for z in range(dimensions.z):
				createBlockMesh(Vector3i(x, y, z))

	surfaceTool.set_material(blockManager.chunkMaterial)

	var surface = surfaceTool.commit()
	mesh.mesh = surface
	collider.shape = surface.create_trimesh_shape()

	print(
		"Generated {vertices} vertices ({triangles} triangles, {faces} faces)".format(
			{
				"vertices": surface.surface_get_array_len(0),
				"triangles": surface.surface_get_array_len(0) / 3,
				"faces": (surface.surface_get_array_len(0) / 3) / 2
			}
		)
	)


## Populates [member blocks] with [Block]s.
func generate():
	for x in range(dimensions.x):
		for y in range(dimensions.y):
			for z in range(dimensions.z):
				var block: Block

				var groundHeight = 24

				if y < groundHeight / 2:
					block = blockManager.stone
				elif y < groundHeight:
					block = blockManager.dirt
				elif y == groundHeight:
					block = blockManager.grass
				else:
					block = blockManager.air

				blocks[Vector3i(x, y, z)] = block


func createBlockMesh(blockPosition: Vector3i):
	var block = blocks[Vector3i(blockPosition)]

	if block == blockManager.air:
		return

	if checkTransparent(blockPosition + Vector3i.UP):
		createFaceMesh(top, blockPosition, block.topTexture if block.topTexture else block.texture)
	if checkTransparent(blockPosition + Vector3i.DOWN):
		createFaceMesh(bottom, blockPosition, block.bottomTexture if block.bottomTexture else block.texture)
	if checkTransparent(blockPosition + Vector3i.LEFT):
		createFaceMesh(left, blockPosition, block.texture)
	if checkTransparent(blockPosition + Vector3i.RIGHT):
		createFaceMesh(right, blockPosition, block.texture)
	if checkTransparent(blockPosition + Vector3i.FORWARD):
		createFaceMesh(front, blockPosition, block.texture)
	if checkTransparent(blockPosition + Vector3i.BACK):
		createFaceMesh(back, blockPosition, block.texture)


func createFaceMesh(face: Array[int], blockPosition: Vector3i, texture: Texture2D):
	var texturePosition = blockManager.getTextureAtlasPosition(texture)
	var textureAtlasSize = blockManager.textureAtlasSize

	var uvOffset = Vector2(texturePosition) / textureAtlasSize
	var uvWidth = 1.0 / textureAtlasSize.x
	var uvHeight = 1.0 / textureAtlasSize.y

	var uvA = uvOffset + Vector2(0, 0)
	var uvB = uvOffset + Vector2(0, uvHeight)
	var uvC = uvOffset + Vector2(uvWidth, uvHeight)
	var uvD = uvOffset + Vector2(uvWidth, 0)

	var a = vertices[face[0]] + blockPosition
	var b = vertices[face[1]] + blockPosition
	var c = vertices[face[2]] + blockPosition
	var d = vertices[face[3]] + blockPosition

	var uvTopLeftTriangle = [uvA, uvB, uvC]
	var uvBottomRightTriangle = [uvA, uvC, uvD]

	var topLeftTriangle = [a, b, c]
	var bottomRightTriangle = [a, c, d]

	var normal = (Vector3(c - a)).cross(Vector3(b - a)).normalized()
	var normals: Array[Vector3] = [normal, normal, normal]

	surfaceTool.add_triangle_fan(topLeftTriangle, uvTopLeftTriangle, normals)
	surfaceTool.add_triangle_fan(bottomRightTriangle, uvBottomRightTriangle, normals)


func checkTransparent(blockPosition: Vector3i):
	if blockPosition.x < 0 || blockPosition.x >= dimensions.x:
		return true
	if blockPosition.y < 0 || blockPosition.y >= dimensions.y:
		return true
	if blockPosition.z < 0 || blockPosition.z >= dimensions.z:
		return true

	return blocks[blockPosition] == blockManager.air

func setBlock(blockPosition: Vector3i, block: Block):
	blocks[blockPosition] = block
	update()

func setChunkPosition(position: Vector2i):
	chunkManager.updateChunkPosition(self, position, chunkPosition)

	chunkPosition = position
	global_position = Vector3(chunkPosition.x * dimensions.x, 0, chunkPosition.y * dimensions.z)

	generate()
	update()