import std.array;
import gfm.opengl, gfm.math, gfm.sdl2;
import engine;
import inputhandler, player, limiter, perlin,
    doxel_world, doxel_stage, doxel_scene, doxel_pieces, doxel_height_map,
    chunk_stage_world_generator, world_surface_generator, chunk_column_provider,
    skybox, quadoverlay;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Player player;
  OpenGL gl;
  InputHandler input;

  World world;
  ChunkStage chunkStage; // to become obsolete
  PieceStage pieceStage;

  Skybox skybox;
  ChunkScene chunkSceneStandard;
  ChunkScene chunkScenePoints;
  ChunkScene waterScene;
  ChunkScene skeletonScene;

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
    camera.setPosition(vec3f(4,4,10));

    world = new World();

    // create scenes
    skybox = new Skybox(gl, camera);

    setupWaterScene();
    setupStandardScene();
    setupPointScene();
    setupSkeletonScene();

    setupPieceStage();
    //setupStage();
	  //setupColumnSiteHandler();
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

  void setupSkeletonScene()
  {
    SceneProgramSkeleton sceneProgramSkeleton = new SceneProgramSkeleton(gl);
    UniformSetter setter = new PvmSetter(sceneProgramSkeleton.program, camera, "PVM");
    SkeletonMeshBuilder skeletonMeshBuilder = new SkeletonMeshBuilder();
    IChunkModelFactory skeletonModelFac = new SkeletonModelFactory(gl, sceneProgramSkeleton.vertexSpec, skeletonMeshBuilder);
    IChunkSceneObjectFactory sceneObjFac = new ChunkSceneObjectFactory(skeletonModelFac, setter);
    skeletonScene = new ChunkScene(camera, sceneProgramSkeleton, sceneObjFac);
  }

  void setupPieceStage()
  {
    RangeSettings rangeSettings = new RangeSettings( [ RangeSetting(0, 32, 42), RangeSetting(1, 100, 140) ] );
    //FracRange[] ranges = [ FracRange(0, 32, 42), FracRange(2, 200, 250) ];
    //FracRange[] ranges = [ FracRange(0, 16, 42) ];
    IFracRangeChecker rangeChecker = new FracRangeChecker(rangeSettings);
    auto upToRank3 = ScenesInRank(3, [chunkSceneStandard, skeletonScene]);
    IRankScenes rankScenes = new RankScenes( [ upToRank3 ] );
    PieceFactory pieceFactory = new PieceFactory(rankScenes);

    int seed = 3;
    IHeightProvider heightProvider = createHeightProvider(seed);
    WorldSurfaceGenerator surfaceGenerator = new WorldSurfaceGenerator(world, heightProvider, seed);
    ChunkColumnProvider chunkProvider = new ChunkColumnProvider(world, surfaceGenerator);
    auto processor = new QueueProcessor(heightProvider, chunkProvider);

    IPieceUnfracker unfracker = new PieceUnfracker();
    PieceQueueProvider queueProvider = new PieceQueueProvider(pieceFactory, rangeChecker, unfracker);
    IPieceUnloader unloader = new PieceUnloader( queueProvider.getPieceMap() );
    auto oldQueueProcessor = new OldQueueProcessor(rangeChecker, unfracker, unloader);

    pieceStage = new PieceStage(camera, queueProvider, processor, oldQueueProcessor);
  }

  // to become obsolete...
  /*void setupStage()
  {
    float pLoadRange = 240;
    float tLoadRange = 140;

    Zone[int] zones = [
      1: Zone(pLoadRange, 1.1*pLoadRange, [chunkScenePoints]),
      2: Zone(tLoadRange, 1.1*tLoadRange, [chunkSceneStandard, waterScene])
    ];

    Limiter chunkLimiter = new Limiter(30); // limits the number of chunk columns checked
    Limiter modelLimiter = new Limiter(10); // limits the number of models created

    int seed = 3;
    IHeightProvider heightProvider = createHeightProvider(seed);
    WorldSurfaceGenerator surfaceGenerator = new WorldSurfaceGenerator(world, heightProvider, seed);
    ChunkStageWorldGenerator generator = new ChunkStageWorldGenerator(camera, world, chunkLimiter, surfaceGenerator);
    IChunkStageObjectFactory chunkStageObjectFactory = new ChunkStageObjectFactory(camera, zones, modelLimiter);
    chunkStage = new ChunkStage(chunkStageObjectFactory, modelLimiter, generator);
  }*/

  IHeightProvider createHeightProvider(int seed)
  {
    Perlin perlin = new Perlin(seed);
    int cellSize = 128;  // 128
    int depthRange = 64; // 64
    HeightGenerator heightGenerator = new HeightGenerator(perlin, cellSize, depthRange); // noise, cell size, range
    auto heightMap = new HeightMap();
    return new HeightProvider(heightGenerator, heightMap);
  }

  ~this()
  {
    chunkStage.destroy;
    chunkSceneStandard.destroy;
    chunkScenePoints.destroy;
    skybox.destroy;
    waterScene.destroy;
    skeletonScene.destroy;
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
    //chunkStage.update(dt_ms);
    pieceStage.update();
  }
  
  void draw()
  {
    skybox.draw();
    chunkScenePoints.draw();
    glClear(GL_DEPTH_BUFFER_BIT);
    chunkSceneStandard.draw();
    waterScene.draw();
    skeletonScene.draw();
  }
}