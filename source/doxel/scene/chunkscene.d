import std.container;
import gfm.opengl, gfm.math;
import engine;
import limiter, doxel_world, doxel_scene;
class ChunkScene
{
  private Camera camera;
  private DList!SceneObject sceneObjects;
  private IChunkSceneObjectFactory fac;
  private ISceneProgram sceneProgram;
  OpenGL gl;
  this(OpenGL gl, Camera camera, ISceneProgram sceneProgram, IChunkSceneObjectFactory fac)
  {
    this.gl = gl;
    this.camera = camera;
    this.sceneProgram = sceneProgram;
    this.fac = fac;
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
    SceneObject sceneObject = fac.createSceneObject(chunks);
    sceneObjects.insert(sceneObject);
    return sceneObject;
  }

  void draw()
  {
    sceneProgram.program.use();
    gl.runtimeCheck();//DEBUG
    sceneProgram.setUniforms();
    gl.runtimeCheck();//DEBUG
    foreach(obj; sceneObjects)
    {
      vec3f[8] boxCorners = obj.getBBCorners();
      if(camera.frustumContains(boxCorners))
      {
        obj.draw();
      }
    }
    sceneProgram.program.unuse();
    gl.runtimeCheck();//DEBUG
  }
}