import std.array, std.stdio, std.random, std.math;
import gfm.opengl, gfm.math, gfm.sdl2;
import engine;
import inputhandler, player,
    chunk_world, chunk_game,
    blocks, limiter,
    skybox, chunkscene, quadoverlay, skeletonscene,
    perlin, heightmap;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Player player;
  OpenGL gl;
  InputHandler input;

  Skybox skybox;
  ChunkScene chunkScene;
  SkeletonScene skeletonScene;

  World world;
  Limiter chunkLimiter;
  WorldSurfaceChunkGenerator generator;

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

    setWorldGenerator();

    // create scenes
    skybox = new Skybox(gl, camera);
    chunkScene = new ChunkScene(gl, camera, world);
    skeletonScene = new SkeletonScene(gl, camera);

    // load font
    /*this.ttf = new SDLTTF(context.sdl);
    this.font = new SDLFont(this.ttf, "resources/fonts/consola.ttf", 14);
    this.surface = this.font.renderTextSolid("HIHAHO YOYOYOYOYOYO", SDL_Color(0,0,0,255));
    this.renderer = new SDL2Renderer(surface);
    this.sdlTexture = new SDL2Texture(renderer, surface);
    this.surface.destroy;
    this.font.destroy;*/

    //this.quadModel = new QuadOverlay(gl);
  }

  ~this()
  {
    chunkScene.destroy;
    skybox.destroy;
    skeletonScene.destroy;

    /*this.ttf.destroy;
    this.renderer.destroy;
    this.sdlTexture.destroy;
    //this.surface.destroy;
    //this.font.destroy;*/
  }

  void initialize()
  {
    setGlSettings();
  }

  void setWorldGenerator()
  {
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    int cellSize = 128;  // 128
    int depthRange = 64; // 64
    HeightMap heightMap = new HeightMap(perlin, cellSize, depthRange); // noise, cell size, range
    this.world = new World();
    
    this.chunkLimiter = new Limiter(40);
    this.generator = new WorldSurfaceChunkGenerator(world, heightMap);
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW); // clockwise faces are front
    glClearColor(100.0/255, 149.0/255, 237.0/255, 1.0); // cornflower blue
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

  vec2i lastCamRel_ij = vec2i(9999,9999);
  vec2i[] genSites;
  int genSiteIndex;
  int genSiteCounter;

  void updateWorldGeneration(double dt_ms)
  {
    vec2i centerRel_ij = vec2i(
      cast(int)floor(camera.position.x/8),
      cast(int)floor(camera.position.y/8)
    );

    if(centerRel_ij != lastCamRel_ij)
    {
      genSites = [centerRel_ij];
      genSiteIndex = 0;
      genSiteCounter = 1;
      // go in spiral...
      int shell = 0;
      vec2i next_ij = centerRel_ij;
      vec2i[3] dirs = [vec2i(-1,-1), vec2i(1,-1), vec2i(1,1)];
      while(shell < 60)
      {
        // go up
        next_ij = next_ij + vec2i(0,1);
        genSites ~= next_ij;
        genSiteCounter++;
        // go upleft
        foreach(n; 0..shell)
        {
          next_ij = next_ij + vec2i(-1,1);
          genSites ~= next_ij;
          genSiteCounter++;
        }
        shell++; // expand shell;
        foreach(dir; dirs)
        {
          foreach(n; 0..shell)
          {
            next_ij = next_ij + dir;
            genSites ~= next_ij;
            genSiteCounter++;
          }
        }
      }
      lastCamRel_ij = centerRel_ij;
      genSiteIndex = 0;
    }

    int columsPerModel = 4;
    while(!chunkLimiter.limitReached() && genSiteCounter > 0)
    {
      auto genSite = genSites[genSiteIndex];
      genSiteIndex++;
      if(!hasBeenVisited( genSite ))
      {
        generator.generateChunkColumn( genSite );
        markAsVisited( genSite );
        bool createNewModel = genSiteIndex % columsPerModel == 0;

        if(createNewModel)
        {
          auto newObject = chunkScene.createChunkObject(world.getNewChunks());

          //VertexP[8] lineVerts;
          //foreach(i, v; newObject.getBBCorners()) lineVerts[i] = VertexP(v);
          //skeletonScene.createHexaHedron(lineVerts);

          chunkLimiter.increment();
          world.clearNewChunks();
        }
      }
      genSiteCounter--;
    }
  }

  void update(double dt_ms)
  {
    chunkLimiter.reset();
    input.update();
    camera.update(dt_ms);
    player.update(dt_ms);
    updateWorldGeneration(dt_ms);
    chunkScene.update(dt_ms);
  }
  
  void draw()
  {
    skybox.draw();
    chunkScene.draw();
    skeletonScene.draw();

    /*renderer.clear();
    renderer.copy(sdlTexture, 10, 10);
    renderer.present();*/
    
    //glBindTexture(GL_TEXTURE_2D, sdlTexture.access());
    //glColor3f(1, 0, 0);
    //quadModel.draw(); 
  }
}