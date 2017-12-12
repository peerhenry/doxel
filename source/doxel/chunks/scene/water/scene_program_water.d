import gfm.opengl, gfm.math;
import engine, i_scene_program;

class SceneProgramWater: ISceneProgram
{
  private
  {
    GLProgram _program;
    Camera _cam;
    VertexSpecification!VertexPT _spec;
    Texture _normalMap;
  }

  @property GLProgram program(){ return _program; }
  @property VertexSpecification!VertexPT vertexSpec(){ return _spec; }
  
  this(OpenGL gl, Camera cam)
  {
    createProgram(gl);
    _cam = cam;
    initUniforms();
    _normalMap = new Texture(gl, _program, "NormalMap", "resources/water/4.jpg");
  }

  private void createProgram(OpenGL gl)
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/water.glsl");
    _program = new GLProgram(gl, shader_source);
    _spec = new VertexSpecification!VertexPT(_program);
  }

  private void initUniforms()
  {
    vec3f lightDir = vec3f(0.8, -0.3, -1.0);
    lightDir.normalize();
    assert(lightDir.length() < 1.1);
    _program.uniform("LightDirection").set( lightDir );
    _program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    _program.uniform("AmbientColor").set( vec3f(0.4, 0.4, 0.4) );
    _program.uniform("PVM").set( mat4f.identity );
    _program.uniform("ViewPosition").set( vec3f(1, 0, 0) );
    _program.uniform("Model").set( mat4f.identity );
  }

  ~this()
  {
	_normalMap.destroy;
    _program.destroy;
    _spec.destroy;
  }

  private float _time = 0;

  void setUniforms()
  {
    _time += 0.005;
    if(_time >= 1) _time = 0;
    _program.uniform("Time").set( _time );
    _program.uniform("ViewPosition").set( _cam.position );
    _normalMap.bind();
  }
}