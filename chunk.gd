extends StaticBody3D


@export var collider: CollisionShape3D
@export var mesh: MeshInstance3D
# @export var noise: FastNoiseLite

var dimensions = Vector3i(32,32,32)

var vertices = [
    Vector3i(0, 0, 0), # 0 | left  | bottom | front
    Vector3i(1, 0, 0), # 1 | right | bottom | front
    Vector3i(0, 1, 0), # 2 | left  |  top   | front
    Vector3i(1, 1, 0), # 3 | right |  top   | front
    Vector3i(0, 0, 1), # 4 | left  | bottom | back
    Vector3i(1, 0, 1), # 5 | right | bottom | back
    Vector3i(0, 1, 1), # 6 | left  |  top   | back
    Vector3i(1, 1, 1)  # 7 | right |  top   | back
]

var top: Array[int] =    [2, 3, 7, 6]
var bottom: Array[int] = [0, 4, 5, 1]
var left: Array[int] =   [6, 4, 0, 2]
var right: Array[int] =  [3, 1, 5, 7]
var front: Array[int] =  [2, 0, 1, 3]
var back: Array[int] =   [7, 5, 4, 6]

var surfaceTool = SurfaceTool.new()

var blocks: Dictionary

func _ready():
    generate()
    update()


## Generate the [member mesh] and [member collider]
func update():
    surfaceTool.begin(Mesh.PRIMITIVE_TRIANGLES)
    for x in range(dimensions.x):
        for y in range(dimensions.y):
            for z in range(dimensions.z):
                createBlockMesh(Vector3i(x, y, z))

    var surface = surfaceTool.commit()
    mesh.mesh = surface
    collider.shape = surface.create_trimesh_shape()

    print("Generated {vertices} vertices ({triangles} triangles, {faces} faces)".format(
        {
            "vertices": surface.surface_get_array_len(0), 
            "triangles": surface.surface_get_array_len(0) / 3,
            "faces": (surface.surface_get_array_len(0) / 3) / 2
        }
        ))


## Populates [member blocks] with [Block]s.
func generate():
    var block: Block = Block.new()

    for x in range(dimensions.x):
        for y in range(dimensions.y):
            for z in range(dimensions.z):
                blocks[Vector3i(x,y,z)] = block

func createBlockMesh(blockPosition: Vector3i):
    if checkTransparent(blockPosition + Vector3i.UP):
        createFaceMesh(top, blockPosition)
    if checkTransparent(blockPosition + Vector3i.DOWN):
        createFaceMesh(bottom, blockPosition)
    if checkTransparent(blockPosition + Vector3i.LEFT):
        createFaceMesh(left, blockPosition)
    if checkTransparent(blockPosition + Vector3i.RIGHT):
        createFaceMesh(right, blockPosition)
    if checkTransparent(blockPosition + Vector3i.FORWARD):
        createFaceMesh(front, blockPosition)
    if checkTransparent(blockPosition + Vector3i.BACK):
        createFaceMesh(back, blockPosition)

func createFaceMesh(face: Array[int], blockPosition: Vector3i):
    var a = vertices[face[0]] + blockPosition
    var b = vertices[face[1]] + blockPosition
    var c = vertices[face[2]] + blockPosition
    var d = vertices[face[3]] + blockPosition

    var topLeftTriangle = [a, b, c]
    var bottomRightTriangle = [a, c, d]

    surfaceTool.add_triangle_fan(topLeftTriangle)
    surfaceTool.add_triangle_fan(bottomRightTriangle)

func checkTransparent(blockPosition: Vector3i):
    if blockPosition.x < 0 || blockPosition.x >= dimensions.x: return true
    if blockPosition.y < 0 || blockPosition.y >= dimensions.y: return true
    if blockPosition.z < 0 || blockPosition.z >= dimensions.z: return true