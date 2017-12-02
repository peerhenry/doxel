import gfm.math, gfm.opengl;

import engine;

class PvmNormalMatrixSetter : UniformSetter!mat4f
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

  void setUniform(mat4f model)
  {
    mat3f normalMatrix = cast(mat3f)model;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform(pvmName).set( pvm ); // PVM
    this.program.uniform(normalName).set( normalMatrix ); // NormalMatrix
  }
}