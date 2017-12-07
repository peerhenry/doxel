import engine;
import chunk;

interface IChunkModelFactory
{
  Drawable createModel(Chunk chunk);

  /// The relChunk will determine the render origin
  /// the chunks in the array will be displaced relative to that in order to achieve proper vertex position
  Drawable createModel(Chunk[] chunks, Chunk relChunk);
}