import std.math;
import gfm.math, gfm.opengl;
import engine;

/*class ChunkObjectFactory
{
  private Camera camera;
  private IChunkModelFactory modelFactory;
  private UniformSetter uniformSetter;
  private Limiter modelLimiter;

  this(Camera camera, IChunkModelFactory modelFactory, UniformSetter uniformSetter, Limiter modelLimiter)
  {
    this.camera = camera;
    this.modelFactory = modelFactory;
    this.uniformSetter = uniformSetter;
    this.modelLimiter = modelLimiter;
  }

  BaseChunkGameObject createChunkObject(Chunk chunk)
  {
    ChunkGameObject chunkObject = new ChunkSingleGameObject(null, uniformSetter, null, chunk); // updater, uniformsetter, drawbehavior, modelmatrix
    Updatable chunkUpdateBehavior = new ChunkUpdateBehavior(camera, chunkObject, modelFactory, modelLimiter);
    chunkObject.setUpdateBehavior(chunkUpdateBehavior);
    return chunkObject;
  }
  
  BaseChunkGameObject createChunkObject(Chunk[] chunks)
  {
    if(chunks.length == 1) return createChunkObject(chunks[0]);
    Chunk[] chunksDuplicate = chunks.dup;
    ChunkArrayGameObject chunkObject = new ChunkArrayGameObject(null, uniformSetter, null, chunksDuplicate); // updater, uniformsetter, drawbehavior, modelmatrix
    Updatable chunkUpdateBehavior = new ChunkArrayUpdate(camera, chunkObject, modelFactory, modelLimiter);
    chunkObject.setUpdateBehavior(chunkUpdateBehavior);
    return chunkObject;
  }
}*/