import std.array, std.stdio, std.random;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import inputhandler, 
    blocks, chunk, region, world, 
    chunkmodelfactory, worldmodelprovider;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Model!VertexPNT[] models;
  OpenGL gl;
  InputHandler input;
  VertexSpecification!VertexPNT vertexSpec;
  Texture texture;

  World world;
  WorldModelProvider provider;

  this(OpenGL gl, InputHandler input, Camera camera)
  {
    this.gl = gl;
    this.input = input;
    input.setGame(this);
    this.camera = camera;
    camera.setPosition(vec3f(0,0,10));
    this.createProgram();
    this.texture = new Texture(gl, this.program, "Atlas", "atlas.png"); // gl, program, shader uniform name, image path
    //this.texture = new Texture(gl, this.program, "Skybox", "skybox.png"); // gl, program, shader uniform name, image path
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
    this.world = new World();
    for(int i = -20; i<20; i++)
    {
      for(int j = -20; j<20; j++)
      {
        //int seed = 12353;
        //auto rnd = Random(seed);
        int h = uniform(0, 3);
        world.setBlock(i,j,h,Block.GRASS);
        world.setBlockColumn(i,j,h-1,3,Block.DIRT);
        world.setBlockColumn(i,j,h-4,10,Block.STONE);
      }
    }

    ModelSetter modelSetter = new PvmNormalMatrixSetter(this.program, this.camera);
    auto chunkFac = new ChunkModelFactory(gl, vertexSpec, modelSetter, world);
    this.provider = new WorldModelProvider(chunkFac, world);
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

  void clickRemoveBlock()
  {
    vec3f campos = camera.position;
    vec3f camdir = camera.direction;
    // calculate line intersection with chunk, and then with block
  }

  void update()
  {
    input.update();
    camera.update();
    if(provider.chunksToGo())
    {
      models ~= provider.getNextChunkModels(10);
    }
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