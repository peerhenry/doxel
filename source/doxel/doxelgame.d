import std.array, std.stdio, std.random;

import gfm.opengl, gfm.math, gfm.sdl2;

import engine;

import inputhandler, 
    blocks, chunk, region, world, skybox,
    chunkmeshbuilder, chunkmodelfactory, chunkobjectfactory, chunkgameobject,
    perlin, heightmap, worldsurfacechunkgenerator;

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
  WorldSurfaceChunkGenerator generator;

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
    setWorldGenerator();
    setGlSettings();
    initUniforms();
  }

  void setWorldGenerator()
  {
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    int cellSize = 32;
    int depthRange = 16;
    HeightMap heightMap = new HeightMap(perlin, cellSize, depthRange); // noise, cell size, range
    this.world = new World();

    ChunkMeshBuilder meshBuilder = new ChunkMeshBuilder(world);
    ChunkModelFactory modelFactory = new ChunkModelFactory(gl, vertexSpec, meshBuilder);
    UniformSetter!mat4f modelSetter = new PvmNormalMatrixSetter(this.program, this.camera, "PVM", "NormalMatrix"); // strings are uniform names in shader
    auto chunkFac = new ChunkObjectFactory(this.camera, modelFactory, modelSetter);
    this.generator = new WorldSurfaceChunkGenerator(world, heightMap, chunkFac);
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

  bool[string] visited;

  void markAsVisited(vec2i centerRel_ij)
  {
    visited[centerRel_ij.toString()] = true;
  }

  bool hasBeenVisited(vec2i centerRel_ij)
  {
    return (centerRel_ij.toString() in visited) !is null;
  }

  void update()
  {
    input.update();
    camera.update();

    // spawn chunks around the player
    // get chunksite containing the camera.
    import std.math;
    vec2i centerRel_ij = vec2i(
      cast(int)floor(camera.position.x/8),
      cast(int)floor(camera.position.y/8)
    );

    foreach(ii; -15 .. 16)
    {
      foreach(jj; -15 .. 16)
      {
        vec2i next_ij = centerRel_ij + vec2i(ii, jj);
        if(!hasBeenVisited(next_ij))
        {
          ChunkGameObject[] newObjects = generator.generateChunkColumn(next_ij);
          this.gameObjects ~= newObjects;
          markAsVisited(next_ij);
        }
      }
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