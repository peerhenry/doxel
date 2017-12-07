import gfm.opengl, gfm.math;
import engine, i_scene_program;
class SceneProgramStandard: ISceneProgram
{
  private
  {
    GLProgram _program;
    VertexSpecification!VertexPNT spec;
    Texture texture;
  }

  @property GLProgram program(){ return _program; }
  @property VertexSpecification!VertexPNT vertexSpec(){ return spec; }
  
  this(OpenGL gl)
  {
    createProgram(gl);
    this.texture = new Texture(gl, _program, "Atlas", "resources/atlas.png"); // gl, program, shader uniform name, image path
    initUniforms();
  }

  private void createProgram(OpenGL gl)
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/standard.glsl");
    _program = new GLProgram(gl, shader_source);
    spec = new VertexSpecification!VertexPNT(_program);
  }

  private void initUniforms()
  {
    _program.uniform("LightDirection").set( vec3f(0.8, -0.3, -1.0).normalized() );
    _program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    _program.uniform("AmbientColor").set( vec3f(0.4, 0.4, 0.4) );
    _program.uniform("MaterialColor").set( vec3f(1, 1, 1) );
    _program.uniform("PVM").set( mat4f.identity );
    _program.uniform("NormalMatrix").set( mat3f.identity );
    texture.bind();
  }

  ~this()
  {
    _program.destroy;
    spec.destroy;
    texture.destroy;
  }

  void setUniforms()
  {
    texture.bind();
  }
}