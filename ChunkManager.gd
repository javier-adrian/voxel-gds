extends Node

var chunkToPosition: Dictionary
var positionToChunk: Dictionary

var chunks: Array

var chunkInstance = Chunk.new()

func _ready():
	chunks = get_parent().get_children().filter(func(i): return i is Chunk)

	for i in chunks:
		i = i as Chunk

func updateChunkPosition(chunk: Chunk, currentPosition: Vector2i, previousPosition: Vector2i):
	if positionToChunk.has(previousPosition):
		if positionToChunk[previousPosition] == chunk:
			positionToChunk.erase(previousPosition)
	
	chunkToPosition[chunk] = currentPosition
	positionToChunk[currentPosition] = chunk

func setBlock(globalPosition: Vector3i, block: Block):
	var chunkTilePosition = Vector2i(floori(globalPosition.x / float(chunkInstance.dimensions.x)), floori(globalPosition.z / float(chunkInstance.dimensions.z)))
	if (positionToChunk.has(chunkTilePosition)):
		positionToChunk[chunkTilePosition].setBlock(Vector3i(globalPosition - Vector3i(positionToChunk[chunkTilePosition].global_position)), block)
