import gfm.math, gfm.opengl;
import engine;

class PvmModelSetter : UniformSetter
{
  private Camera camera;
  private GLProgram program;
  string pvmName;
  string modelUniformName;

  this(GLProgram program, Camera camera, string pvmUniformName, string modelUniformName)
  {
    this.camera = camera;
    this.program = program;
    this.pvmName = pvmUniformName;
    this.modelUniformName = modelUniformName;
  }

  void setUniforms(SceneObject sceneObject)
  {
    mat4f model = sceneObject.modelMatrix;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    this.program.uniform(pvmName).set( pvm ); // PVM
    this.program.uniform(modelUniformName).set( model ); // Model
  }
}