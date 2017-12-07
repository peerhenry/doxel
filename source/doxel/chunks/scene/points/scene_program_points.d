import gfm.opengl, gfm.math;
import engine, i_scene_program;
class SceneProgramPoints: ISceneProgram
{
  private
  {
    Camera cam;
    GLProgram _program;
    VertexSpecification!VertexPC spec;
  }

  @property GLProgram program(){ return _program; }
  @property VertexSpecification!VertexPC vertexSpec() { return spec; }
  
  this(OpenGL gl, Camera cam)
  {
    this.cam = cam;
    createProgram(gl);
    initUniforms();
  }

  private void createProgram(OpenGL gl)
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/colorpoints.glsl");
    _program = new GLProgram(gl, shader_source);
    spec = new VertexSpecification!VertexPC(program);
  }

  private void initUniforms()
  {
    _program.uniform("LightDirection").set( vec3f(0.8, -0.3, -1.0).normalized() );
    _program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    _program.uniform("AmbientColor").set( vec3f(0.4, 0.4, 0.4) );
    _program.uniform("PVM").set( mat4f.identity );
    _program.uniform("Model").set( mat4f.identity );
    _program.uniform("CamPos").set( cam.position );
  }

  ~this()
  {
    _program.destroy;
    spec.destroy;
  }

  void setUniforms()
  {
    _program.uniform("CamPos").set( cam.position );
  }
}