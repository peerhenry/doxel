import gfm.opengl, gfm.math;
import engine;
import i_scene_program;

class SceneProgramSkeleton: ISceneProgram
{
  private{
    GLProgram _program;
    VertexSpecification!VertexP _spec;
  }
  UniformSetter setter;

  @property GLProgram program(){ return _program; }
  @property VertexSpecification!VertexP vertexSpec() { return _spec; }

  this(OpenGL gl)
  {
    createProgram(gl);
  }

  ~this()
  {
    _program.destroy;
    _spec.destroy;
  }

  private void createProgram(OpenGL gl)
  {
    string[] shader_source = readLines("source/doxel/glsl/vertexposition.glsl");
    _program = new GLProgram(gl, shader_source);
    _spec = new VertexSpecification!VertexP(_program);
    _program.uniform("Color").set(vec3f(1,0,0));
    _program.uniform("PVM").set(mat4f.identity);
  }

  /*void createCamFrustum()
  {
    vec3f[8] vecs = cam.getFrustumCorners();
    VertexP[8] vertices;
    foreach(i; 0..8) vertices[i] = VertexP(vecs[i]);
    createHexaHedron(vertices);
  }

  void createHexaHedron(VertexP[8] vertices)
  {
    Drawable draw = new HexaHedron(gl, spec, vertices);
    auto newObj = new GameObject(null, setter, draw, mat4f.identity);
    addGameObject(newObj);
  }*/

  void setUniforms(){}
}