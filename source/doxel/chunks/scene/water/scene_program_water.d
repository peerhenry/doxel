import gfm.opengl, gfm.math;
import engine, i_scene_program;

class SceneProgramWater: ISceneProgram
{
  private
  {
    GLProgram _program;
    VertexSpecification!VertexP spec;
  }

  @property GLProgram program(){ return _program; }
  @property VertexSpecification!VertexP vertexSpec(){ return spec; }
  
  this(OpenGL gl)
  {
    createProgram(gl);
    initUniforms();
  }

  private void createProgram(OpenGL gl)
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/water.glsl");
    _program = new GLProgram(gl, shader_source);
    spec = new VertexSpecification!VertexP(_program);
  }

  private void initUniforms()
  {
    _program.uniform("PVM").set( mat4f.identity );
  }

  ~this()
  {
    _program.destroy;
    spec.destroy;
  }

  void setUniforms()
  {
    
  }
}