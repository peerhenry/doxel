import std.math, std.array, std.stdio, std.format;
import gfm.math;
import iregion, iregioncontainer, chunk, region, sides, blocks, sitecalculator;

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
    worldSiteOrigin[1] = vec3i(4,4,2);
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
    vec3i chunkSite = vec3i(
      4 + cast(int)floor((cast(float)i)/8),
      4 + cast(int)floor((cast(float)j)/8),
      2 + cast(int)floor((cast(float)k)/4)
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
      _topRegion = new Region(this.topRegion);
    }

    IRegionContainer container = this.topRegion;
    // Get or create regions down the ranks
    while(container.getRank() > 2)
    {
      if(container.getRank() > maxRank+1)
      {
        container = cast(IRegionContainer) container.getCreateRegion(vec3i(4,4,2));
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

  Chunk getAdjacentChunk(Chunk chunk, SideDetails side)
  {
    return cast(Chunk)getAdjacentRegion(chunk, side);
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
      container = new Region(region);
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