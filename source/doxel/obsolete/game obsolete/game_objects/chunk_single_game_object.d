
/*class ChunkSingleGameObject : ChunkGameObject
{
  private Chunk chunk;
  Chunk getChunk(){return chunk;}

  this(Updatable updateBehavior, UniformSetter uniformSetBehavior, Drawable drawBehavior, Chunk chunk)
  {
    vec3f chunkPos = chunk.getPosition();
    mat4f modelMatrix = mat4f.translation(chunkPos);
    this.chunk = chunk;
    super(updateBehavior, uniformSetBehavior, drawBehavior, modelMatrix);
  }

  override void draw()
  {
    super.draw();
  }

  box3f getBoundingBox()
  {
    vec3f chunkPos = chunk.getPosition();
    return box3f(chunkPos.x, chunkPos.x+8, chunkPos.y, chunkPos.y+8, chunkPos.z, chunkPos.z+4);
  }

  vec3f[8] getBBCorners()
  {
    vec3f chunkPos = chunk.getPosition();
    return [
      vec3f(chunkPos.x, chunkPos.y, chunkPos.z),
      vec3f(chunkPos.x, chunkPos.y, chunkPos.z+4),
      vec3f(chunkPos.x, chunkPos.y+8, chunkPos.z),
      vec3f(chunkPos.x, chunkPos.y+8, chunkPos.z+4),
      vec3f(chunkPos.x+8, chunkPos.y, chunkPos.z),
      vec3f(chunkPos.x+8, chunkPos.y, chunkPos.z+4),
      vec3f(chunkPos.x+8, chunkPos.y+8, chunkPos.z),
      vec3f(chunkPos.x+8, chunkPos.y+8, chunkPos.z+4)
    ];
  }
}*/