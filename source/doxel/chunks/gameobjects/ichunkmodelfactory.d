import engine;
import chunk;

alias ChunkModel = Model!VertexPNT;

interface IChunkModelFactory
{
  ChunkModel createModel(Chunk chunk);
}