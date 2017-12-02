import std.math;
import gfm.math, gfm.opengl;
import engine;
import chunk, chunkgameobject, ichunkmodelfactory;

class ChunkUpdateBehavior: Updatable
{
  private ChunkGameObject chunkObject;
  private Camera camera;
  private IChunkModelFactory modelFactory;

  this(Camera camera, ChunkGameObject chunkObject, IChunkModelFactory modelFactory)
  {
    this.camera = camera;
    this.chunkObject = chunkObject;
    this.modelFactory = modelFactory;
  }

  private bool chunkIsWithinLoadRange()
  {
    return squaredDistanceFromCam() < 100*100;
  }

  private bool chunkIsOutsideUnloadRange()
  {
    return squaredDistanceFromCam() > 150*150;
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
      if(cast(DefaultDraw)chunkObject.getDrawBehavior() !is null)
      {
        chunkObject.getDrawBehavior().destroy;
        VertexModel model = modelFactory.createModel(chunkObject.chunk);
        chunkObject.setDrawBehavior(model);
      }
    }
    else if(chunkIsOutsideUnloadRange())
    {
      if(cast(VertexModel)chunkObject.getDrawBehavior() !is null)
      {
        chunkObject.getDrawBehavior().destroy;
        chunkObject.setDrawBehavior(new DefaultDraw());
      }
    }
  }
}