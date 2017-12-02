import std.math;
import gfm.math, gfm.opengl;
import engine;
import chunk, chunkgameobject, ichunkmodelfactory, iregioncontainer, chunkupdatebehavior, limiter;

class ChunkObjectFactory
{
  private Camera camera;
  private IChunkModelFactory modelFactory;
  private UniformSetter!mat4f uniformSetter;
  private Limiter limiter;

  this(Camera camera, IChunkModelFactory modelFactory, UniformSetter!mat4f uniformSetter, Limiter limiter)
  {
    this.camera = camera;
    this.modelFactory = modelFactory;
    this.uniformSetter = uniformSetter;
    this.limiter = limiter;
  }

  ChunkGameObject createChunkObject(Chunk chunk)
  {
    vec3i site = chunk.getSite();
    vec3f location = vec3f((site.x-4)*8.0, (site.y-4)*8.0, (site.z-2)*4.0);
    IRegionContainer container = chunk.getContainer();
    while(container !is null)
    {
      vec3f cSite = container.getSite();
      int rank = container.getRank();
      location.x = location.x + (cSite.x-4)*pow(8.0, rank);
      location.y += (cSite.y-4)*pow(8.0, rank);
      location.z += (cSite.z-2)*pow(4.0, rank);
      container = container.getContainer();
    }
    mat4f modelMatrix = mat4f.translation(location);
    Mat4fSetAction uniformSetAction = new Mat4fSetAction(uniformSetter, modelMatrix);
    ChunkGameObject chunkObject = new ChunkGameObject(null, uniformSetAction, null);
    chunkObject.chunk = chunk;
    Updatable chunkUpdateBehavior = new ChunkUpdateBehavior(camera, chunkObject, modelFactory, limiter);
    chunkObject.setUpdateBehavior(chunkUpdateBehavior);
    return chunkObject;
  }
}