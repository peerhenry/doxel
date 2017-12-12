import std.random, std.math;
import gfm.math;
import engine;
import world_surface_generator, limiter, world, chunkstage, perlin, height_generator, height_map, height_provider, worldsettings;
class ChunkStageWorldGenerator
{
  private Camera cam;
  private World world;
  private WorldSurfaceGenerator surfaceGenerator;
  private Limiter chunkLimiter;

  private bool[string] visited;
  private vec2i lastCamRel_ij = vec2i(900, 900);
  private vec2i[] genSites;
  private int genSiteIndex;
  private int genSiteCounter;

  this(Camera cam, World world, Limiter chunkLimiter, WorldSurfaceGenerator surfaceGenerator)
  {
    this.cam = cam;
    this.world = world;
    this.chunkLimiter = chunkLimiter;
    this.surfaceGenerator = surfaceGenerator;
  }

  void update(ChunkStage chunkStage)
  {
    chunkLimiter.reset();
    setupGenerationSites();
    createStageObjects(chunkStage);
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
      cast(int)floor(cam.position.x/regionWidth),
      cast(int)floor(cam.position.y/regionHeight)
    );

    if(centerRel_ij != lastCamRel_ij && centerRel_ij.squaredDistanceTo(lastCamRel_ij) > regionWidth*regionWidth)
    {
      newSpiral = true;
      genSites = [centerRel_ij];
      genSiteIndex = 0;
      genSiteCounter = 1;
      // go in spiral...
      int shell = 0;
      vec2i next_ij = centerRel_ij;
      vec2i[3] dirs = [vec2i(-1,-1), vec2i(1,-1), vec2i(1,1)];
      while(shell < (100*8/regionWidth))
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

  void createStageObjects(ChunkStage chunkStage)
  {
    int columsPerObject = 1;
    //if(genSiteCounter > 100) columsPerObject = 8;
    //if(genSiteCounter > 1000) columsPerObject = 16;
    while(!chunkLimiter.limitReached() && genSiteCounter > 0)
    {
      auto genSite = genSites[genSiteIndex];
      genSiteIndex++;
      if(!hasBeenVisited( genSite ))
      {
        surfaceGenerator.generateChunkColumn( genSite );
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