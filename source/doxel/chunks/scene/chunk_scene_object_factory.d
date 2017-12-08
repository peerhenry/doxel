import std.math;
import gfm.math, gfm.opengl;
import engine;
import doxel_world, doxel_scene, i_chunk_scene_object_factory, worldsettings;

class ChunkSceneObjectFactory: IChunkSceneObjectFactory
{
  private IChunkModelFactory modelFactory;
  private UniformSetter uniformSetter;

  this(IChunkModelFactory modelFactory, UniformSetter uniformSetter)
  {
    this.modelFactory = modelFactory;
    this.uniformSetter = uniformSetter;
  }

  SceneObject createSceneObject(Chunk chunk)
  {
    return createSceneObject([chunk]);
  }
  
  SceneObject createSceneObject(Chunk[] chunks)
  {
    // import std.stdio; writeln("Now creating scene object with chunk count: ", chunks.length);
    Chunk[] chunksDuplicate = chunks.dup;
    Chunk bottomChunk;
    vec3f min = vec3f(float.max, float.max, float.max);
    float FLOAT_MIN = -9999999.0;
    vec3f max = vec3f(FLOAT_MIN, FLOAT_MIN, FLOAT_MIN);
    foreach(chunk; chunksDuplicate)
    {
      vec3f nextPos = chunk.getPosition();
      if(nextPos.x + regionWidth > max.x) max.x = nextPos.x + regionWidth;
      if(nextPos.y + regionLength > max.y) max.y = nextPos.y + regionLength;
      if(nextPos.z + regionHeight > max.z) max.z = nextPos.z + regionHeight;
      if(nextPos.x < min.x) min.x = nextPos.x;
      if(nextPos.y < min.y) min.y = nextPos.y;
      if(nextPos.z < min.z)
      {
        min.z = nextPos.z;
        bottomChunk = chunk;
      }
    }
    mat4f modelMatrix = mat4f.translation(bottomChunk.getPosition());
    Drawable model = modelFactory.createModel(chunksDuplicate, bottomChunk);
    ChunkSceneObject sceneObject = new ChunkSceneObject(uniformSetter, modelMatrix, model, min, max);
    return sceneObject;
  }
}