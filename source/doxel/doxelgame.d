module doxel.doxelgame;

import std.array, std.stdio;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import doxel.cube, inputhandler, cubegenerator_pnt;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Model!VertexPNT[] models;
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
    foreach(m; this.models)
    {
      m.destroy;
    }
    this.texture.destroy;
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
    ModelSetter modelSetter = new PvmNormalMatrixSetter(this.program, this.camera);
    auto gen = new CubeGenerator(gl, vertexSpec, modelSetter);
    this.models ~= gen.generateCube( vec3f(0,0,0) );
    this.models ~= gen.generateCube( vec3f(3,3,0) );
    this.models ~= gen.generateCube( vec3f(-3,-3,0) );
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
    this.program.uniform("LightDirection").set( vec3f(0.8, -0.3, -1.0).normalized() );
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
    foreach(m; this.models)
    {
      m.draw();
    }
    program.unuse();
  }
}