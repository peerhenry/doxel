import engine;
import chunk;
interface IChunkMeshBuilder(VertexType)
{
  Mesh!VertexType buildChunkMesh(Chunk chunk);

  Mesh!VertexType buildChunkMesh(Chunk[] chunk, Chunk originChunk);
}