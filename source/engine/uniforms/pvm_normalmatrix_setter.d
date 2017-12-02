import gfm.math, gfm.opengl;
import engine, gameobject;

class PvmNormalMatrixSetter : UniformSetter
{
  private Camera camera;
  private GLProgram program;
  string pvmName;
  string normalName;

  this(GLProgram program, Camera camera, string pvmUniformName, string normalMatrixUniformName)
  {
    this.camera = camera;
    this.program = program;
    this.pvmName = pvmUniformName;
    this.normalName = normalMatrixUniformName;
  }

  void setUniforms(GameObject gameobject)
  {
    mat4f model = gameobject.getModelMatrix();
    mat3f normalMatrix = cast(mat3f)model;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform(pvmName).set( pvm ); // PVM
    this.program.uniform(normalName).set( normalMatrix ); // NormalMatrix
  }
}