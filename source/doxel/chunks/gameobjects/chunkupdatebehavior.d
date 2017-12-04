import std.math;
import gfm.math, gfm.opengl;
import engine;
import chunk, chunkgameobject, ichunkmodelfactory, limiter;

class ChunkUpdateBehavior: Updatable
{
  private ChunkGameObject chunkObject;
  private Camera camera;
  private IChunkModelFactory modelFactory;
  private Limiter limiter;
  private static const LOAD_RANGE = 256;
  private static const LOAD_RANGE_SQUARED = LOAD_RANGE*LOAD_RANGE;
  private static const UNLOAD_RANGE_SQUARED = (LOAD_RANGE+50)*(LOAD_RANGE+50);
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
    vec3f chunkPos = chunkObject.chunk.getRelativePositionFrom(center) + vec3f(4,4,2); // add the center of the chunk
    vec3f diff = chunkPos - campos;
    float sqDistance = diff.x*diff.x + diff.y*diff.y + diff.z*diff.z;
    return sqDistance;
  }

  alias VertexModel = Model!VertexPNT;

  void update()
  {
    if(chunkIsWithinLoadRange())
    {
      if(!hasModel && !limiter.limitReached())
      {
        chunkObject.getDrawBehavior().destroy;
        VertexModel model = modelFactory.createModel(chunkObject.chunk);
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