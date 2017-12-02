import std.math;
import gfm.opengl, gfm.math;
import engine;

class Skybox
{
  private:
    OpenGL gl;
    Camera camera;
    GLProgram program;
    CubeMap texture;
    VertexSpecification!VertexP vertexSpec;
    Model!VertexP cube;
  public:

  this(OpenGL gl, Camera camera)
  {
    this.gl = gl;
    this.camera = camera;
    string[] shader_source = readLines("source/doxel/glsl/skybox.glsl");
    this.program = new GLProgram(gl, shader_source);
    this.vertexSpec = new VertexSpecification!VertexP(this.program);
    loadSkybox();
    createCube();
    this.program.uniform("Projection").set(camera.projection);
    this.program.uniform("View").set(camera.view);
  }

  ~this()
  {
    this.texture.destroy;
    this.cube.destroy;
    this.program.destroy;
  }

  void loadSkybox()
  {
    this.texture = new CubeMap(gl, program, "cubeMap"
    , "resources/skybox/top.png"
    , "resources/skybox/bottom.png"
    , "resources/skybox/front.png"
    , "resources/skybox/back.png"
    , "resources/skybox/left.png"
    , "resources/skybox/right.png");
    this.texture.bind();
  }

  void createCube()
  {
    VertexP[8] vertices;
    foreach(i; 0..8)
    {
      vertices[i] = VertexP(vec3f(cube_vertices[3*i], cube_vertices[3*i+1], cube_vertices[3*i+2]));
    }
    Mesh!VertexP mesh = Mesh!VertexP(vertices, cube_indices);
    this.cube = new Model!VertexP(gl, vertexSpec, mesh);
  }
  
  void draw()
  {
    program.use();
    program.uniform("Projection").set(camera.projection);
    float theta = camera.getTheta();
    float phi = camera.getPhi();
    vec3f dir = vec3f(cos(-theta)*cos(phi), sin(phi), sin(-theta)*cos(phi));
    mat4f skyboxView = mat4f.lookAt(vec3f(0,0,0), dir, vec3f(0,1,0));
    program.uniform("View").set(skyboxView);
    glDepthMask(0);
    texture.bind();
    cube.draw();
    glDepthMask(1);
    program.unuse();
  }

  // DATA

  GLfloat[] cube_vertices = [
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,
    1.0, -1.0,  1.0,
    1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
    1.0, -1.0, -1.0,
    1.0,  1.0, -1.0,
  ];

  /*GLuint[] cube_indices = [
    0, 1, 2, 3,
    3, 2, 6, 7,
    7, 6, 5, 4,
    4, 5, 1, 0,
    0, 3, 7, 4,
    1, 2, 6, 5,
  ];*/

  GLuint[] cube_indices = [
    0, 1, 2, 2, 3, 0,
    3, 2, 6, 6, 7, 3,
    7, 6, 5, 5, 4, 7,
    4, 5, 1, 1, 0, 4,
    0, 3, 7, 7, 4, 0,
    1, 2, 6, 6, 5, 1
  ];
};