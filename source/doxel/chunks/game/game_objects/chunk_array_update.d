import std.math;
import gfm.math, gfm.opengl;
import engine;
import chunk, chunk_game, limiter, base_chunk_update;

class ChunkArrayUpdate: BaseChunkUpdate
{
  private ChunkArrayGameObject chunkObject;
  private Camera camera;
  private IChunkModelFactory modelFactory;
  private Limiter limiter;
  private bool hasModel;

  this(Camera camera, ChunkArrayGameObject chunkObject, IChunkModelFactory modelFactory, Limiter limiter)
  {
    this.camera = camera;
    this.chunkObject = chunkObject;
    this.modelFactory = modelFactory;
    this.limiter = limiter;
  }

  private bool chunkIsWithinLoadRange()
  {
    return squaredDistanceFromCam() < LOAD_RANGE_SQUARED;
  }

  private bool chunkIsOutsideUnloadRange()
  {
    return squaredDistanceFromCam() > UNLOAD_RANGE_SQUARED;
  }

  private float squaredDistanceFromCam()
  {
    vec3f campos = camera.position;
    vec3f mChunkCenter = chunkObject.getCenter(); // add the center of the chunk
    vec3f diff = mChunkCenter - campos;
    float sqDistance = diff.x*diff.x + diff.y*diff.y + diff.z*diff.z;
    return sqDistance;
  }
  
  void update()
  {
    if(chunkIsWithinLoadRange())
    {
      if(!hasModel && !limiter.limitReached())
      {
        chunkObject.getDrawBehavior().destroy;
        Drawable model = modelFactory.createModel(chunkObject.getChunks(), chunkObject.bottomChunk);
        chunkObject.setDrawBehavior(model);
        hasModel = true;
        limiter.increment();
      }
    }
    else if(chunkIsOutsideUnloadRange())
    {
      if(hasModel)
      {
        chunkObject.getDrawBehavior().destroy;
        chunkObject.setDrawBehavior(new DefaultDraw());
        hasModel = false;
      }
    }
  }
}