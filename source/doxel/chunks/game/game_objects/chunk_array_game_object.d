import gfm.math;
import engine;
import chunk, base_chunk_game_object;
class ChunkArrayGameObject : BaseChunkGameObject
{
  private Chunk[] chunks;
  private Chunk _bottomChunk;
  @property Chunk bottomChunk() { return _bottomChunk; }
  private vec3f min;
  private vec3f max;

  this(Updatable updateBehavior, UniformSetter uniformSetBehavior, Drawable drawBehavior, Chunk[] chunks)
  {
    this.chunks = chunks;
    _bottomChunk = chunks[0];
    vec3f pos1 = chunks[0].getPosition();
    min = pos1;
    max = pos1;
    foreach(chunk; chunks)
    {
      vec3f nextPos = chunk.getPosition();
      if(nextPos.x+8 > max.x) max.x = nextPos.x+8;
      if(nextPos.y+8 > max.y) max.y = nextPos.y+8;
      if(nextPos.z+4 > max.z) max.z = nextPos.z+4;
      if(nextPos.x < min.x) min.x = nextPos.x;
      if(nextPos.y < min.y) min.y = nextPos.y;
      if(nextPos.z < min.z)
      {
        min.z = nextPos.z;
        _bottomChunk = chunk;
      }
    }
    
    mat4f modelMatrix = mat4f.translation(_bottomChunk.getPosition());
    super(updateBehavior, uniformSetBehavior, drawBehavior, modelMatrix);
  }

  Chunk[] getChunks(){return chunks;}
  vec3f getMin(){return min;}
  vec3f getMax(){return max;}
  vec3f getCenter(){return (min+max)*0.5;}

  box3f getBoundingBox()
  {
    return box3f(min.x, max.x, min.y, max.y, min.z, max.z);
  }

  vec3f[8] getBBCorners()
  {
    return [
      vec3f(min.x, min.y, min.z),
      vec3f(min.x, min.y, max.z),
      vec3f(min.x, max.y, min.z),
      vec3f(min.x, max.y, max.z),
      vec3f(max.x, min.y, min.z),
      vec3f(max.x, min.y, max.z),
      vec3f(max.x, max.y, min.z),
      vec3f(max.x, max.y, max.z)
    ];
  }
}