import engine;
import chunk;
interface IChunkSceneObjectFactory
{
  SceneObject createSceneObject(Chunk chunks);
  SceneObject createSceneObject(Chunk[] chunks);
}