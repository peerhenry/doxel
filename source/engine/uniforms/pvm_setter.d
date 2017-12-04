import gfm.math, gfm.opengl;
import engine, gameobject;

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

  void setUniforms(GameObject gameobject)
  {
    mat4f model = gameobject.getModelMatrix();
    mat3f normalMatrix = cast(mat3f)model;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform(pvmName).set( pvm ); // PVM
  }
}