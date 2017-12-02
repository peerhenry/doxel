import gfm.math;

import engine;

import chunk, quadgenerator_pnt, blocks, sides, world, sitecalculator;

vec3i siteIndexToSite(int index)
{
  int i = index%8;
  int k = index/64;
  int j = (index-k*64)/8;
  return vec3i(i,j,k);
}

alias ChunkMesh = Mesh!VertexPNT;

class ChunkMeshBuilder
{
  World world;

  this(World world)
  {
    this.world = world;
  }

  bool isTranslucent(Block block)
  {
    if(block == Block.EMPTY) return true;
    if(block == Block.WATER) return true;
    return false;
  }

  ChunkMesh buildChunkMesh(Chunk chunk)
  {
    VertexPNT[] vertices;
    uint[] indices;
    int counter;
    foreach(int i, block; chunk.blocks)
    {
      if(block == Block.EMPTY) continue;
      counter++;
      vec3i site = siteIndexToSite(i);
      foreach(sd; allSides) // sd is short for SideDetails
      {
        if(sd.side == Side.Bottom) continue;
        vec3i adjSite = site + cast(vec3i)sd.normal;
        bool withinBounds = adjSite.x >= 0 && adjSite.x < 8 && adjSite.y >= 0 && adjSite.y < 8 && adjSite.z >= 0 && adjSite.z < 4;
        Block adjBlock = Block.EMPTY;
        if(withinBounds) adjBlock = chunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
        else
        {
          Chunk adjChunk = world.getAdjacentChunk(chunk, sd);
          if(adjChunk !is null)
          {
            adjSite = SiteCalculator.siteModulo(adjSite);
            adjBlock = adjChunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
          }
        }

        bool shouldAddQuad = isTranslucent(block) ? adjBlock == Block.EMPTY : isTranslucent(adjBlock);

        if(shouldAddQuad)
        {
          vec3f quadCenter = (block == Block.WATER && sd.side == Side.Top) ? vec3f(0, 0, 0.85) : sd.normal;
          vec3f faceCenter = vec3f(site.x + 0.5*(1 + quadCenter.x), site.y + 0.5*(1 + quadCenter.y), site.z + 0.5*(1 + quadCenter.z));
          vertices ~= generateQuad(sd.side, faceCenter, getAtlasij(block, sd.side));
          uint li = 0;
          if(indices.length > 0) li = indices[indices.length-1]+1;
          indices ~= [li,li+1,li+2,li+2,li+1,li+3];
        }
      }
    }
    
    return Mesh!VertexPNT(vertices, indices);
  }
}