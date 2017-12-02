import std.algorithm;
import engine;
import iregion, iregioncontainer, chunk, world, chunkobjectfactory;

class WorldObjectProvider
{
  private ChunkObjectFactory factory;
  private Chunk[] chunks;
  private int nextIndex;

  this(ChunkObjectFactory factory, World world)
  {
    this.factory = factory;
    this.chunks = getChunks(world.topRegion);
  }

  /// Are there still chunks that have not been converted to models?
  bool chunksToGo()
  {
    return nextIndex < chunks.length;
  }

  GameObject[] getNextChunkObjects(int amount)
  {
    int newNextIndex = min(nextIndex + amount, chunks.length);
    GameObject[] objects;
    foreach(i; nextIndex..newNextIndex) // 0..3 => 0,1,2
    {
      GameObject newObj = factory.createChunkObject(chunks[i]);
      objects ~= newObj;
    }
    nextIndex = newNextIndex;
    return objects;
  }

  Chunk[] getChunks(IRegionContainer region)
  {
    IRegion[] regions = region.getRegions();
    Chunk[] chunks;

    if(region.getRank() == 2) // rank 2 means the region is a chunk container
    {
      foreach(reg; regions)
      {
        if(reg !is null)
        {
          chunks ~= cast(Chunk)reg;
        }
      }
    }
    else
    {
      foreach(reg; regions)
      {
        if(reg is null) continue;
        chunks ~= getChunks(cast(IRegionContainer)reg);
      }
    }
    return chunks;
  }
}