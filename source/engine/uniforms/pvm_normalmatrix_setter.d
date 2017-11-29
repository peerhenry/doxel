import gfm.math, gfm.opengl;

import engine;

import modelsetter;

class PvmNormalMatrixSetter : ModelSetter
{
  private Camera camera;
  private GLProgram program;

  this(GLProgram program, Camera camera)
  {
    this.camera = camera;
    this.program = program;
  }

  void set(mat4f model)
  {
    mat3f normalMatrix = cast(mat3f)model;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform("PVM").set( pvm );
    this.program.uniform("NormalMatrix").set( normalMatrix );
  }
}