import std.algorithm;
import engine;
import iregion, iregioncontainer, chunk, world, chunkmodelfactory;

class WorldModelProvider
{
  private ChunkModelFactory modelFac;
  private Chunk[] chunks;
  private int nextIndex;

  this(ChunkModelFactory modelFac, World world)
  {
    this.modelFac = modelFac;
    this.chunks = getChunks(world.topRegion);
  }

  /// Are there still chunks that have not been converted to models?
  bool chunksToGo()
  {
    return nextIndex < chunks.length;
  }

  Model!VertexPNT[] getNextChunkModels(int amount)
  {
    int newNextIndex = min(nextIndex + amount, chunks.length);
    Model!VertexPNT[] models;
    foreach(i; nextIndex..newNextIndex) // 0..3 => 0,1,2
    {
      Model!VertexPNT newModel = modelFac.generateChunkModel(chunks[i]);
      models ~= newModel;
    }
    nextIndex = newNextIndex;
    return models;
  }

  Chunk[] getChunks(IRegionContainer region)
  {
    Model!VertexPNT[] models;
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