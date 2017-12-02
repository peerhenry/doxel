import gfm.opengl;
import engine;

/*class Skybox
{
  private:
    OpenGL gl;
    GLProgram program;
    CubeMap texture;
    VertexSpecification!VertexP vertexSpec;
  public:

  this(OpenGL gl)
  {
    this.gl = gl;
    string[] shader_source = readLines("source/doxel/glsl/skybox.glsl");
    this.program = new GLProgram(gl, shader_source);
    this.vertexSpec = new VertexSpecification!VertexP(this.program);
    loadSkybox();
    createCube();
  }

  ~this()
  {
    this.texture.destroy;
  }

  void loadSkybox()
  {
    this.texture = new CubeMap(gl, program, "cubeMap"
    , "skybox/top.png"
    , "skybox/bottom.png"
    , "skybox/front.png"
    , "skybox/back.png"
    , "skybox/left.png"
    , "skybox/right.png");
  }

  void createCube()
  {
    
  }
  
  void draw()
  {
    glDepthMask(0);
    glBindVertexArray(uiVAO);
    this.texture.bind();
    glDrawElements(GL_QUADS, sizeof(cube_indices)/sizeof(GLushort), GL_UNSIGNED_SHORT, 0);
    glDepthMask(1);
  }

  // DATA

  GLfloat cube_vertices[] = {
    -1.0,  1.0,  1.0,
    -1.0, -1.0,  1.0,
    1.0, -1.0,  1.0,
    1.0,  1.0,  1.0,
    -1.0,  1.0, -1.0,
    -1.0, -1.0, -1.0,
    1.0, -1.0, -1.0,
    1.0,  1.0, -1.0,
  };

  GLushort cube_indices[] = {
    0, 1, 2, 3,
    3, 2, 6, 7,
    7, 6, 5, 4,
    4, 5, 1, 0,
    0, 3, 7, 4,
    1, 2, 6, 5,
  };
};*/