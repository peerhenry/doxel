import engine;
import chunk;
interface IChunkStageObjectFactory
{
  Updatable createStageObject(Chunk chunk);

  Updatable createStageObject(Chunk[] chunk);
}