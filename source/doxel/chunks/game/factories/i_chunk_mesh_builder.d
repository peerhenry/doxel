import engine;
import chunk;
interface IChunkMeshBuilder
{
  Mesh!VertexPNT buildChunkMesh(Chunk chunk);

  Mesh!VertexPNT buildChunkMesh(Chunk[] chunk, Chunk originChunk);
}