import std.random, std.math;
import gfm.math;
import engine;
import world_surface_chunk_generator, limiter, world, chunkstage, perlin, heightmap;
class ChunkStageWorldGenerator
{
  private Camera cam;
  private World world;
  private ChunkStage chunkStage;
  private WorldSurfaceChunkGenerator generator;
  private Limiter chunkLimiter;

  private bool[string] visited;
  private vec2i lastCamRel_ij = vec2i(900, 900);
  private vec2i[] genSites;
  private int genSiteIndex;
  private int genSiteCounter;

  this(Camera cam, World world, ChunkStage chunkStage, Limiter chunkLimiter)
  {
    this.cam = cam;
    this.world = world;
    this.chunkStage = chunkStage;
    this.chunkLimiter = chunkLimiter;
    setWorldGenerator();
  }

  void setWorldGenerator()
  {
    int seed = 3;
    Perlin perlin = new Perlin(seed);

    int cellSize = 128;  // 128
    int depthRange = 64; // 64
    HeightMap heightMap = new HeightMap(perlin, cellSize, depthRange); // noise, cell size, range
    this.generator = new WorldSurfaceChunkGenerator(world, heightMap);
  }

  void update(double dt_ms)
  {
    chunkLimiter.reset();
    setupGenerationSites();
    createStageObjects();
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

    if(centerRel_ij != lastCamRel_ij && centerRel_ij.squaredDistanceTo(lastCamRel_ij) > 16)
    {
      newSpiral = true;
      genSites = [centerRel_ij];
      genSiteIndex = 0;
      genSiteCounter = 1;
      // go in spiral...
      int shell = 0;
      vec2i next_ij = centerRel_ij;
      vec2i[3] dirs = [vec2i(-1,-1), vec2i(1,-1), vec2i(1,1)];
      while(shell < 200)
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

  bool newSpiral;
  import std.stdio;

  void createStageObjects()
  {
    int columsPerObject = 4;
    if(genSiteCounter > 100) columsPerObject = 8;
    if(genSiteCounter > 1000) columsPerObject = 16;
    while(!chunkLimiter.limitReached() && genSiteCounter > 0)
    {
      auto genSite = genSites[genSiteIndex];
      genSiteIndex++;
      if(!hasBeenVisited( genSite ))
      {
        generator.generateChunkColumn( genSite );
        markAsVisited( genSite );
        bool createGameObject = genSiteIndex % columsPerObject == 0;

        if(createGameObject)
        {
          chunkStage.createStageObject(world.getNewChunks());
          world.clearNewChunks();
        }
        
        chunkLimiter.increment();
      }
      genSiteCounter--;
    }
    if(genSiteCounter == 0 && newSpiral)
    {
      writeln("genSiteCounter has reached zero.");
      newSpiral = false;
    }
  }

}