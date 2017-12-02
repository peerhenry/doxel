import std.math, std.array, std.stdio;;
import gfm.math;
import iregion, iregioncontainer, chunk, region, sides, blocks, sitecalculator;

alias Calc = SiteCalculator;

class World
{
  IRegionContainer topRegion;
  Appender!(Chunk[]) newChunks;

  this()
  {
    this.topRegion = new Region(2);
    newChunks = appender!(Chunk[])();
  }

  Chunk[] getNewChunks()
  {
    return newChunks.data();
  }

  void clearNewChunks()
  {
    newChunks.clear();
  }

  /// Add a column of blocks to the world
  void setBlockColumn(int i, int j, int k, int depth, Block block)
  {
    foreach(d; 0..depth)
    {
      setBlock(i, j, k-d, block);
    }
  }

  /// sets a block in the world
  /// coordinates ijk are relative to the central chunk
  void setBlock(int i, int j, int k, Block block)
  {
    vec3i chunkSite = vec3i(
      4 + cast(int)floor((cast(float)i)/8),
      4 + cast(int)floor((cast(float)j)/8),
      2 + cast(int)floor((cast(float)k)/4)
    );
    Chunk chunk = getCreateChunk(chunkSite);
    vec3i blockSite = Calc.siteModulo(vec3i(i,j,k));
    chunk.setBlock(blockSite.x, blockSite.y, blockSite.z, block);
  }

  Chunk getCreateChunk(vec3i site)
  {
    // dictionary with int keys and vec3i values.
    vec3i[int] worldSite = Calc.toWorldSite(site);
    int maxRank = SiteCalculator.getMaxRank(worldSite);

    while(maxRank >= this.topRegion.getRank()) // the topregion must be 1 rank above max rank in worldsite.
    {
      this.topRegion = new Region(this.topRegion);
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
        // writeln(format!"now using worldSite to access a region of rank %s regSite: %s"((container.getRank() - 1), regSite.toString())); // DEBUG
        container = cast(IRegionContainer) container.getCreateRegion(regSite);
      }
    }
    auto chunk = container.getRegion(worldSite[1]);
    if(chunk is null)
    {
      // writeln(format!"now creating chunk in world with container site %s"(container.getSite().toString())); // DEBUG
      if(container is null) writeln("A chunk is being created with a null container :/");
      auto newChunk = new Chunk(container, worldSite[1]);
      newChunks ~= newChunk;
      return newChunk;
    }
    else
    {
      /*string msg1 = format!"NOT creating chunk in region: %s site: %s"(container.getRank(), container.getSite().toString());
      string msg2 = format!"Chunk would have had site: %s"(worldSite[1].toString());
      writeln( msg1 );
      writeln( msg2 );*/
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

  IRegion getCreateAdjacentRegion(IRegion region, SideDetails side)
  {
    vec3i adjSite = region.getSite() + side.normali;
    bool outOfBounds = Calc.isOutOfBounds(adjSite);
    if(outOfBounds)
    {
      Region adjacentContainer = cast(Region)getCreateAdjacentRegion(region.getContainer(), side);
      vec3i inBoundsSite = Calc.siteModulo(adjSite);
      return adjacentContainer.getCreateRegion(inBoundsSite);
    }
    else
    {
      IRegionContainer container;
      if(region is this.topRegion)
      {
        container = new Region(region);
        this.topRegion = container;
      }
      else
      {
        container = region.getContainer();
      }
      return container.getCreateRegion(adjSite);
    }
  }
}