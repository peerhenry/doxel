import gfm.math, gfm.opengl;
import engine;

class PvmSetter : UniformSetter
{
  private Camera camera;
  private GLProgram program;
  string pvmName;

  this(GLProgram program, Camera camera, string pvmUniformName)
  {
    this.camera = camera;
    this.program = program;
    this.pvmName = pvmUniformName;
  }

  void setUniforms(SceneObject sceneObject)
  {
    mat4f model = sceneObject.modelMatrix;
    mat3f normalMatrix = cast(mat3f)model;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform(pvmName).set( pvm ); // PVM
  }
}