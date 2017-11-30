module doxel.doxelgame;

import std.array, std.stdio;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import inputhandler, cubegenerator_pnt, chunk, chunkmodelfactory, blocks;

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
    this.texture = new Texture(gl, this.program, "Atlas", "atlas.png"); // gl, program, shader uniform name, image path
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
    /*auto gen = new CubeGenerator(gl, vertexSpec, modelSetter);
    this.models ~= gen.generateCube( vec3f(0,0,0), Block.SAND );
    this.models ~= gen.generateCube( vec3f(3,3,0), Block.STONE );
    this.models ~= gen.generateCube( vec3f(-3,-3,0), Block.GRASS );
    this.models ~= gen.generateCube( vec3f(6,3,0), Block.DIRT );*/

    auto chunkGen = new ChunkModelFactory(gl, vertexSpec, modelSetter);
    auto chunk = new Chunk();
    chunk.setBlock(4,4,2,Block.SAND);
    chunk.setBlock(0,0,0,Block.GRASS);
    chunk.setBlock(0,1,0,Block.SAND);
    chunk.setBlock(1,3,0,Block.STONE);
    chunk.setBlock(2,2,0,Block.GRASS);
    chunk.setBlock(3,2,1,Block.DIRT);
    chunk.setBlock(1,1,1,Block.STONE);
    this.models ~= chunkGen.generateChunkModel(chunk);
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