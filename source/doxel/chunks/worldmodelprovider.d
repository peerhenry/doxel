import engine;

import iregion, iregioncontainer, chunk, world, chunkmodelfactory;

class WorldModelProvider
{
  private ChunkModelFactory modelFac;

  this(ChunkModelFactory modelFac)
  {
    this.modelFac = modelFac;
  }

  Model!VertexPNT[] getChunkModels(World world)
  {
    return getChunkModels(world.topRegion);
  }
  import std.stdio;
  Model!VertexPNT[] getChunkModels(IRegionContainer region)
  {
    Model!VertexPNT[] models;
    IRegion[] regions = region.getRegions();

    if(region.getRank() == 2)
    {
      foreach(reg; regions)
      {
        if(reg !is null)
        {
          Model!VertexPNT newModel = modelFac.generateChunkModel(cast(Chunk)reg);
          models ~= newModel;
        }
      }
    }
    else
    {
      foreach(reg; regions)
      {
        if(reg is null) continue;
        models ~= getChunkModels(cast(IRegionContainer)reg);
      }
    }
    return models;
  }
}