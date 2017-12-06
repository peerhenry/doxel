import std.math;
import gfm.math, gfm.opengl;
import engine;

/*class ChunkSingleUpdate: ChunkUpdateBehavior
{
  private ChunkGameObject chunkObject;
  private Camera camera;
  private IChunkModelFactory modelFactory;
  private Limiter limiter;
  private bool hasModel;

  this(Camera camera, ChunkGameObject chunkObject, IChunkModelFactory modelFactory, Limiter limiter)
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
    vec3i[int] center;
    center[1] = vec3i(4,4,2);
    vec3f chunkCenter = chunkObject.getChunk().getPositionRelativeTo(center) + vec3f(4,4,2); // add the center of the chunk
    vec3f diff = chunkCenter - campos;
    float sqDistance = diff.x*diff.x + diff.y*diff.y + diff.z*diff.z;
    return sqDistance;
  }

  alias VertexModel = Model!VertexPNT;

  void update(double dt_ms)
  {
    if(chunkIsWithinLoadRange())
    {
      if(!hasModel && !limiter.limitReached())
      {
        chunkObject.getDrawBehavior().destroy;
        Drawable model = modelFactory.createModel(chunkObject.getChunk());
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
}*/