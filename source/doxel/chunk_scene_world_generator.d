import std.random, std.math;
import gfm.math;
import engine;
import world_surface_chunk_generator, limiter, world, chunkscene, perlin, heightmap;
class ChunkSceneWorldGenerator
{
  private Camera cam;
  private World world;
  private ChunkScene chunkScene;
  private WorldSurfaceChunkGenerator generator;
  private Limiter chunkLimiter;

  private bool[string] visited;
  private vec2i lastCamRel_ij = vec2i(9999,9999);
  private vec2i[] genSites;
  private int genSiteIndex;
  private int genSiteCounter;

  this(Camera cam, World world, ChunkScene chunkScene)
  {
    this.cam = cam;
    this.world = world;
    this.chunkScene = chunkScene;
    setWorldGenerator();
  }

  void setWorldGenerator()
  {
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    int cellSize = 128;  // 128
    int depthRange = 64; // 64
    HeightMap heightMap = new HeightMap(perlin, cellSize, depthRange); // noise, cell size, range
    
    this.chunkLimiter = new Limiter(40); // limits the amount of sites to check 
    this.generator = new WorldSurfaceChunkGenerator(world, heightMap);
  }

  void update(double dt_ms)
  {
    chunkLimiter.reset();
    setupGenerationSites();
    createModels();
  }

  void markAsVisited(vec2i centerRel_ij)
  {
    visited[centerRel_ij.toString()] = true;
  }

  bool hasBeenVisited(vec2i centerRel_ij)
  {
    return (centerRel_ij.toString() in visited) !is null;
  }

  void setupGenerationSites()
  {
    vec2i centerRel_ij = vec2i(
      cast(int)floor(cam.position.x/8),
      cast(int)floor(cam.position.y/8)
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
  }

  void createModels()
  {
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
          chunkLimiter.increment();
          world.clearNewChunks();
        }
      }
      genSiteCounter--;
    }
  }

}