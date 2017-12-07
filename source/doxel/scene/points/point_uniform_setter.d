import gfm.math, gfm.opengl;
import engine;

class PointUniformSetter : UniformSetter
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

  private float distanceFromCam(SceneObject sceneObject)
  {
    vec3f diff = sceneObject.position - camera.position;
    return diff.length();
  }

  void setUniforms(SceneObject sceneObject)
  {
    mat4f model = sceneObject.modelMatrix;
    mat4f pvm = this.camera.projection * this.camera.view * model;
    float dist = distanceFromCam(sceneObject);
    glPointSize(1300.0/dist);
    this.program.uniform(pvmName).set( pvm ); // PVM
    this.program.uniform(modelUniformName).set( model ); // Model
  }
}