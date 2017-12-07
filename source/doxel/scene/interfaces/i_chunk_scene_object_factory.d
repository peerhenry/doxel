import engine;
import chunk;
interface IChunkSceneObjectFactory
{
  SceneObject createSceneObject(Chunk chunk);
  SceneObject createSceneObject(Chunk[] chunks);
}