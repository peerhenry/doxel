module doxel.doxelgame;

import std.array, std.stdio;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import doxel.cube, inputhandler, quadgenerator;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Model!VertexPNT model;
  OpenGL gl;
  InputHandler input;
  VertexSpecification!VertexPNT vertexSpec;
  Texture texture;

  this(OpenGL gl, InputHandler input, Camera camera)
  {
    this.gl = gl;
    this.input = input;
    this.camera = camera;
    this.createProgram();
    this.texture = new Texture(gl, this.program, "Atlas", "atlas.png");
  }

  ~this()
  {
    this.program.destroy;
    this.vertexSpec.destroy;
    this.model.destroy;
  }

  /// Creates a shader program 
  void createProgram()
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/standard.glsl");
    this.program = new GLProgram(gl, shader_source);
    this.vertexSpec = new VertexSpecification!VertexPNT(this.program);
  }

  void initialize()
  {
    createModels();
    setGlSettings();
    initUniforms();
  }

  void createModels()
  {
    Cube cube = new Cube();
    VertexPNT[] vertexArray;
    ModelSetter modelSetter = new PvmNormalMatrixSetter(this.program, this.camera);
    /*foreach(i; 0..24)
    {
      const int offset = 3*i;

      const float x = cube.positions[offset + 0];
      const float y = cube.positions[offset + 1];
      const float z = cube.positions[offset + 2];

      const float n_x = cube.normals[offset + 0];
      const float n_y = cube.normals[offset + 1];
      const float n_z = cube.normals[offset + 2];

      const float u = cube.uv[2*i];
      const float v = cube.uv[2*i + 1];

      vertexArray[i] = VertexPNT(vec3f(x, y, z), vec3f(n_x, n_y, n_z), vec2f(u, v));
    }*/
    int counter = 0;
    vertexArray ~= generateQuad(Side.Top, vec3f(0,0,0.5), vec2i(0,0));
    vertexArray ~= generateQuad(Side.Bottom, vec3f(0,0,-0.5), vec2i(0,0));
    vertexArray ~= generateQuad(Side.North, vec3f(0,0.5,0), vec2i(0,0));
    vertexArray ~= generateQuad(Side.South, vec3f(0,-0.5,0), vec2i(0,0));
    vertexArray ~= generateQuad(Side.East, vec3f(0.5,0,0), vec2i(0,0));
    vertexArray ~= generateQuad(Side.West, vec3f(-0.5,0,0), vec2i(0,0));
    
    this.model = new Model!VertexPNT(gl, modelSetter, this.vertexSpec, vertexArray, cube.indices);
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW); // clockwise faces are front
    glClearColor(100.0/255, 149.0/255, 237.0/255, 1.0); // cornflower blue
  }

  void initUniforms()
  {
    this.program.uniform("LightDirection").set( vec3f(-0.8, 0.3, -1.0).normalized() );
    this.program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    this.program.uniform("AmbientColor").set( vec3f(0.2, 0.2, 0.2) );
    this.program.uniform("MaterialColor").set( vec3f(1, 1, 1) );
    this.program.uniform("PVM").set( mat4f.identity );
    this.program.uniform("NormalMatrix").set( mat3f.identity );
    this.texture.bind();
  }

  void update()
  {
    input.update();
    camera.update();
  }

  void draw()
  {
    this.program.use();
    this.texture.bind();
    this.model.draw();
    program.unuse();
  }
}