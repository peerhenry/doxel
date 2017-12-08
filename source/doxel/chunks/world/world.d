import std.math, std.array, std.stdio, std.format;
import gfm.math;
import sides, doxel_world;

alias Calc = SiteCalculator;

class World
{
  private IRegionContainer _topRegion;
  @property IRegionContainer topRegion(){ return _topRegion; }
  Appender!(Chunk[]) newChunks;
  private vec3i[int] worldSiteOrigin;

  vec3i[int] getWorldSiteOrigin()
  {
    return worldSiteOrigin;
  }

  void setOrigin(Chunk chunk)
  {
    worldSiteOrigin = chunk.getWorldSite();
  }

  this()
  {
    _topRegion = new Region(2);
    newChunks = appender!(Chunk[])();
    worldSiteOrigin[1] = regionCenter;
  }

  Chunk[] getNewChunks()
  {
    return newChunks.data();
  }

  void clearNewChunks()
  {
    newChunks.clear();
  }

  // == Block/Chunk Get/Set methods

  /// Add a column of blocks to the world
  void setBlockColumn(int i, int j, int k, int depth, Block block)
  {
    //writeln("world.setBlockColumn...");
    foreach(d; 0..depth)
    {
      setBlock(i, j, k-d, block);
    }
  }

  /// sets a block in the world
  /// coordinates ijk are relative to the central chunk
  void setBlock(int i, int j, int k, Block block)
  {
    //writeln("world.setBlock... ", i, j, k, " ", block);
    vec3i chunkSite = regionCenter + vec3i(
      cast(int)floor((cast(float)i)/regionSize.x),
      cast(int)floor((cast(float)j)/regionSize.y),
      cast(int)floor((cast(float)k)/regionSize.z)
    );
    //writeln("Now calling getCreateChunk... ");
    Chunk chunk = getCreateChunk(chunkSite);
    //writeln("Now calling sitemodulo... ");
    vec3i blockSite = Calc.siteModulo(vec3i(i,j,k));
    //writeln("Now ready to set the block in chunk... ");
    chunk.setBlock(blockSite.x, blockSite.y, blockSite.z, block);
  }

  Chunk getCreateChunk(vec3i site)
  {
    // dictionary with int keys and vec3i values.
    vec3i[int] worldSite = Calc.toWorldSite(site);
    int maxRank = SiteCalculator.getMaxRank(worldSite);

    while(maxRank >= this.topRegion.getRank()) // the topregion must be 1 rank above max rank in worldsite.
    {
      _topRegion = Region.createContainerFor(this.topRegion);
    }

    IRegionContainer container = this.topRegion;
    // Get or create regions down the ranks
    while(container.getRank() > 2)
    {
      if(container.getRank() > maxRank+1)
      {
        container = cast(IRegionContainer) container.getCreateRegion(regionCenter);
      }
      else
      {
        vec3i regSite = worldSite[container.getRank() - 1];
        container = cast(IRegionContainer) container.getCreateRegion(regSite);
      }
    }

    auto chunk = container.getRegion(worldSite[1]);
    if(chunk is null)
    {
      auto newChunk = new Chunk(this, container, worldSite[1]);
      newChunks ~= newChunk;
      return newChunk;
    }
    else
    {
      return cast(Chunk) chunk;
    }
  }

  IChunk getAdjacentChunk(IChunk chunk, SideDetails side)
  {
    return cast(IChunk)getAdjacentRegion(chunk, side);
  }

  IRegion getAdjacentRegion(IRegion region, SideDetails side)
  {
    assert(region !is null);
    vec3i adjSite = region.getSite() + side.normali;
    bool outOfBounds = Calc.isOutOfBounds(adjSite);
    if(outOfBounds)
    {
      Region adjacentContainer = cast(Region)getAdjacentRegion(region.getContainer(), side);
      if(adjacentContainer is null) return null;
      vec3i inBoundsSite = Calc.siteModulo(adjSite);
      return adjacentContainer.getRegion(inBoundsSite);
    }
    else
    {
      if(region is this.topRegion)
      {
        return null;
      }
      else
      {
        IRegionContainer container = region.getContainer();
        assert(container !is null);
        return container.getRegion(adjSite);
      }
    }
  }

  /// will create chunk and necessary regions if not present
  Chunk getCreateAdjacentChunk(Chunk chunk, SideDetails side)
  {
    return cast(Chunk)getCreateAdjacentRegion(chunk, side);
  }

  IRegionContainer getCreateContainer(IRegion region)
  {
    IRegionContainer container;
    if(region is this.topRegion)
    {
      container = Region.createContainerFor(region);
      _topRegion = container;
    }
    else
    {
      container = region.getContainer();
    }
    return container;
  }

  IRegion getCreateAdjacentRegion(IRegion region, SideDetails side)
  {
    vec3i adjSite = region.getSite() + side.normali;
    bool outOfBounds = Calc.isOutOfBounds(adjSite);
    IRegionContainer container = getCreateContainer(region);
    if(outOfBounds)
    {
      Region adjacentContainer = cast(Region)getCreateAdjacentRegion(container, side);
      vec3i inBoundsSite = Calc.siteModulo(adjSite);
      if(region.getRank() > 2) return adjacentContainer.getCreateRegion(inBoundsSite);
      else return new Chunk(this, adjacentContainer, inBoundsSite);
    }
    else
    {
      return container.getCreateRegion(adjSite);
    }
  }
}

unittest{
  import testrunner;
  runtest("Chunk center is half chunk size", delegate void(){
    assert(regionCenter.x == regionSize.x/2);
    assert(regionCenter.y == regionSize.y/2);
    assert(regionCenter.z == regionSize.z/2);
  });
}