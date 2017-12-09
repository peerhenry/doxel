import std.container;
import gfm.opengl, gfm.math;
import engine;
import limiter, doxel_world, doxel_scene;

interface ISceneChunkValidator
{
  bool areValid(Chunk[] chunks);
}

class DefaultValidator : ISceneChunkValidator
{
  bool areValid(Chunk[] chunks){return true;}
}

class ChunkScene
{
  private Camera camera;
  private DList!SceneObject sceneObjects;
  private IChunkSceneObjectFactory fac;
  private ISceneProgram sceneProgram;
  private ISceneChunkValidator validator;

  this(Camera camera, ISceneProgram sceneProgram, IChunkSceneObjectFactory fac)
  {
    this.camera = camera;
    this.sceneProgram = sceneProgram;
    this.fac = fac;
    validator = new DefaultValidator();
  }

  void setValidator(ISceneChunkValidator validator)
  {
    this.validator = validator;
  }

  ~this()
  {
    foreach(m; sceneObjects)
    {
      m.destroy;
    }
    sceneProgram.destroy;
  }

  void remove(SceneObject so)
  {
    for (auto rn = sceneObjects[]; !rn.empty;)
    if (rn.front is so)
        sceneObjects.popFirstOf(rn);
    else
        rn.popFront();
  }

  /// Creates a scene object from chunks
  SceneObject createSceneObject(Chunk[] chunks)
  {
    if(!validator.areValid(chunks)) return null;
    SceneObject sceneObject = fac.createSceneObject(chunks);
    sceneObjects.insert(sceneObject);
    return sceneObject;
  }

  void draw()
  {
    sceneProgram.program.use();
    sceneProgram.setUniforms();
    foreach(obj; sceneObjects)
    {
      vec3f[8] boxCorners = obj.getBBCorners();
      if(camera.frustumContains(boxCorners))
      {
        obj.draw();
      }
    }
    sceneProgram.program.unuse();
  }
}