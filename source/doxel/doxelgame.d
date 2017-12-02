import std.array, std.stdio, std.random;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import inputhandler, 
    blocks, chunk, region, world, 
    chunkobjectfactory, worldobjectprovider, perlin, heightmap, skybox;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  GameObject[] gameObjects;
  OpenGL gl;
  InputHandler input;
  VertexSpecification!VertexPNT vertexSpec;
  Texture texture;
  Skybox skybox;

  World world;
  WorldObjectProvider provider;

  this(OpenGL gl, InputHandler input, Camera camera)
  {
    this.gl = gl;
    this.input = input;
    input.setGame(this);
    this.camera = camera;
    camera.setPosition(vec3f(0,0,10));
    this.skybox = new Skybox(gl, camera);
    this.createProgram();
    this.texture = new Texture(gl, this.program, "Atlas", "atlas.png"); // gl, program, shader uniform name, image path
  }

  ~this()
  {
    this.program.destroy;
    this.vertexSpec.destroy;
    foreach(m; this.gameObjects)
    {
      m.destroy;
    }
    this.texture.destroy;
    this.skybox.destroy;
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
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    int cellSize = 32;
    int depthRange = 16;
    HeightMap map = new HeightMap(perlin, cellSize, depthRange); // noise, cell size, range
    this.world = new World();
    int size = 128;
    for(int i = -size; i<size; i++)
    {
      for(int j = -size; j<size; j++)
      {
        //int h = uniform(0, 2);
        int h = map.getHeight(i, j);
        world.setBlock(i,j,h,Block.GRASS);
        world.setBlockColumn(i,j,h-1,3,Block.DIRT);
        world.setBlockColumn(i,j,h-4,-6,Block.STONE);

        if(i%8 == 0 && j%8 == 0)
        {
          bool shouldSpawn = uniform(0, 2) == 1;
          if(shouldSpawn)
          {
            int treeHeight = uniform(4, 7);
            spawnTree(world, i, j, h+1, treeHeight);
          }
        }
      }
    }

    UniformSetter!mat4f modelSetter = new PvmNormalMatrixSetter(this.program, this.camera, "PVM", "NormalMatrix"); // strings are uniform names in shader
    auto chunkFac = new ChunkObjectFactory(gl, vertexSpec, modelSetter, world);
    this.provider = new WorldObjectProvider(chunkFac, world);
  }

  void spawnTree(World world, int i, int j, int k, int height)
  {
    foreach(ii; -1..2)
    {
      foreach(jj; -1..2)
      {
        foreach(kk; -1..2)
        {
          world.setBlock(i + ii, j + jj, k + height + kk, Block.LEAVES);
        }
      }
    }
    foreach(h; 0..height){
      world.setBlock(i,j,k+h,Block.TRUNK);
    }
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glDisable(GL_CULL_FACE);
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
      gameObjects ~= provider.getNextChunkObjects(10);
    }

    foreach(obj; this.gameObjects)
    {
      obj.update();
    }
  }

  void draw()
  {
    skybox.draw();
    this.program.use();
    this.texture.bind();
    foreach(obj; this.gameObjects)
    {
      obj.draw();
    }
    program.unuse();
  }
}