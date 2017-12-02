import std.array, std.stdio, std.random;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import inputhandler, 
    blocks, chunk, region, world, 
    chunkobjectfactory, worldobjectprovider, perlin, heightmap;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  GameObject[] gameObjects;
  OpenGL gl;
  InputHandler input;
  VertexSpecification!VertexPNT vertexSpec;
  Texture texture;

  World world;
  WorldObjectProvider provider;

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
    foreach(m; this.gameObjects)
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
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    /*import std.stdio, std.format;
    auto nA = perlin.getnodes(0.5,0.5);
    auto nB = perlin.getnodes(1.5,0.5);
    auto nC = perlin.getnodes(0.5,1.5);
    auto nD = perlin.getnodes(1.5,1.5);
    writeln(format!"nodes A are: %s, %s, %s, %s"(nA[0].toString(), nA[1].toString(), nA[2].toString(), nA[3].toString()));
    writeln(format!"nodes B are: %s, %s, %s, %s"(nB[0].toString(), nB[1].toString(), nB[2].toString(), nB[3].toString()));
    writeln(format!"nodes C are: %s, %s, %s, %s"(nC[0].toString(), nC[1].toString(), nC[2].toString(), nC[3].toString()));
    writeln(format!"nodes B are: %s, %s, %s, %s"(nD[0].toString(), nD[1].toString(), nD[2].toString(), nD[3].toString()));

    writeln("noise close below 1,1: ", perlin.noise(0.99,0.99), " noise close above 1,1: ", perlin.noise(1.01,1.01));
    writeln("dotGridGradient with 1,1 left-under: ", perlin.dotGridGradient(1,1,0.99,0.99)
    , " right-under 1,1: ", perlin.dotGridGradient(1, 1, 1.01, 0.99)
    , " left-over 1,1: ", perlin.dotGridGradient(1, 1, 0.99, 1.01)
    , " right-over 1,1: ", perlin.dotGridGradient(1, 1, 1.01, 1.01)
    );*/

    HeightMap map = new HeightMap(perlin, 16, 7); // noise, cell size, range
    this.world = new World();
    for(int i = -64; i<64; i++)
    {
      for(int j = -64; j<64; j++)
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
            int treeHeight = uniform(5, 8);
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
    this.program.use();
    this.texture.bind();
    foreach(obj; this.gameObjects)
    {
      obj.draw();
    }
    program.unuse();
  }
}