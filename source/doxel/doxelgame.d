import std.array;
import gfm.opengl, gfm.math, gfm.sdl2;
import engine;
import inputhandler, player, limiter,
    blocks, doxel_world, doxel_stage, doxel_scene, chunk_stage_world_generator,
    perlin, doxel_height_map, height_provider, height_generator, world_surface_generator,
    skybox, quadoverlay, skeletonscene;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Player player;
  OpenGL gl;
  InputHandler input;

  World world;
  ChunkStage chunkStage;

  Skybox skybox;
  ChunkScene chunkSceneStandard;
  ChunkScene chunkScenePoints;
  ChunkScene waterScene;

  SDLTTF ttf;
  SDLFont font;
  SDL2Surface surface;
  SDL2Texture sdlTexture;
  SDL2Renderer renderer;

  QuadOverlay quadModel;

  this(Context context, InputHandler input, Camera camera, Player player)
  {
    this.gl = context.gl;
    this.input = input;
    input.setGame(this);
    this.camera = camera;
    this.player = player;
    camera.setPosition(vec3f(0,0,10));

    world = new World();

    // create scenes
    skybox = new Skybox(gl, camera);

    setupWaterScene();
    setupStandardScene();
    setupPointScene();
    setupStage();
  }

  void setupStandardScene()
  {
    SceneProgramStandard sceneProgram = new SceneProgramStandard(gl);
    UniformSetter pvmNormalSetter = new PvmNormalMatrixSetter( sceneProgram.program, camera, "PVM", "NormalMatrix" );
    StandardMeshBuilder standardMeshBuilder = new StandardMeshBuilder(world);
    IChunkModelFactory standardModelFac = new StandardChunkModelFactory(gl, sceneProgram.vertexSpec, standardMeshBuilder);
    IChunkSceneObjectFactory standardSceneObjectFac = new ChunkSceneObjectFactory(standardModelFac, pvmNormalSetter);
    chunkSceneStandard = new ChunkScene(camera, sceneProgram, standardSceneObjectFac);
  }

  void setupPointScene()
  {
    SceneProgramPoints sceneProgramPoints = new SceneProgramPoints(gl, camera);
    UniformSetter setter2 = new PointUniformSetter(sceneProgramPoints.program, camera, "PVM", "Model");
    //UniformSetter setter2 = new PvmSetter(sceneProgramPoints.program, camera, "PVM");
    PointMeshBuilder pointMeshBuilder = new PointMeshBuilder(world);
    IChunkModelFactory pointModelFac = new PointChunkModelFactory(gl, sceneProgramPoints.vertexSpec, pointMeshBuilder);
    IChunkSceneObjectFactory pointsSceneObjectFac = new ChunkSceneObjectFactory(pointModelFac, setter2);
    chunkScenePoints = new ChunkScene(camera, sceneProgramPoints, pointsSceneObjectFac);
  }

  void setupWaterScene()
  {
    SceneProgramWater sceneProgramWater = new SceneProgramWater(gl, camera);
    UniformSetter setter3 = new PvmModelSetter(sceneProgramWater.program, camera, "PVM", "Model");
    WaterMeshBuilder waterMeshBuilder = new WaterMeshBuilder(world);
    IChunkModelFactory waterModelFac = new WaterChunkModelFactory(gl, sceneProgramWater.vertexSpec, waterMeshBuilder);
    IChunkSceneObjectFactory waterSceneObjectFac = new ChunkSceneObjectFactory(waterModelFac, setter3);
    waterScene = new ChunkScene(camera, sceneProgramWater, waterSceneObjectFac);
    waterScene.setValidator(new WaterSceneChunkValidator());
  }

  void setupStage()
  {
    float pLoadRange = 180;
    float tLoadRange = 140;

    Zone[int] zones = [
      1: Zone(pLoadRange, 1.1*pLoadRange, [chunkScenePoints]),
      2: Zone(tLoadRange, 1.1*tLoadRange, [chunkSceneStandard, waterScene])
    ];

    Limiter chunkLimiter = new Limiter(20); // limits the number of chunk columns checked
    Limiter modelLimiter = new Limiter(5); // limits the number of models created

    int seed = 3;
    Perlin perlin = new Perlin(seed);
    int cellSize = 128;  // 128
    int depthRange = 64; // 64
    HeightGenerator heightGenerator = new HeightGenerator(perlin, cellSize, depthRange); // noise, cell size, range
    auto heightMap = new HeightMap();
    IHeightProvider provider = new HeightProvider(heightGenerator, heightMap);
    WorldSurfaceGenerator surfaceGenerator = new WorldSurfaceGenerator(world, provider, seed);
    ChunkStageWorldGenerator generator = new ChunkStageWorldGenerator(camera, world, chunkLimiter, surfaceGenerator);
    IChunkStageObjectFactory chunkStageObjectFactory = new ChunkStageObjectFactory(camera, zones, modelLimiter);
    chunkStage = new ChunkStage(chunkStageObjectFactory, modelLimiter, generator);
  }

  ~this()
  {
    chunkStage.destroy;
    chunkSceneStandard.destroy;
    chunkScenePoints.destroy;
    skybox.destroy;
    waterScene.destroy;
  }

  void initialize()
  {
    setGlSettings();
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW); // clockwise faces are front
    glClearColor(100.0/255, 149.0/255, 237.0/255, 1.0); // cornflower blue
    glPointSize(1.0);
    glEnable(GL_BLEND); 
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  }

  void clickRemoveBlock()
  {
    vec3f campos = camera.position;
    vec3f camdir = camera.direction;
    // calculate line intersection with chunk, and then with block
  }

  void update(double dt_ms)
  {
    input.update();
    camera.update(dt_ms);
    player.update(dt_ms);
    chunkStage.update(dt_ms);
  }
  
  void draw()
  {
    skybox.draw();
    chunkScenePoints.draw();
    glClear(GL_DEPTH_BUFFER_BIT);
    chunkSceneStandard.draw();
    waterScene.draw();
  }
}