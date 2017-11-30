import gfm.math;

import engine;

import chunk, quadgenerator_pnt, blocks, sides;

Mesh!VertexPNT buildChunkMesh(Chunk chunk)
{
  VertexPNT[] vertices;
  uint[] indices;
  foreach(int i, block; chunk.blocks)
  {
    if(block == Block.EMPTY) continue;
    vec3i site = chunk.indexToCoord(i);
    foreach(sd; allSides)
    {
      vec3i adjSite = site + cast(vec3i)sd.normal;
      bool inBounds = adjSite.x >= 0 && adjSite.x < 8 && adjSite.y >= 0 && adjSite.y < 8 && adjSite.z >= 0 && adjSite.z < 4;
      Block adjBlock = Block.EMPTY;
      if(inBounds) adjBlock = chunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
      else
      {
        // Chunk adjChunk = world.getAdjacentChunk(chunk, sd)
        // adjSite = siteModulo(adjSite);
        // adjBlock = adjChunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
      }
      if(adjBlock == Block.EMPTY)
      {
        vec3f faceCenter = vec3f(site.x + 0.5*(1 + sd.normal.x), site.y + 0.5*(1 + sd.normal.y), site.z + 0.5*(1 + sd.normal.z));
        vertices ~= generateQuad(sd.side, faceCenter, getAtlasij(block, sd.side));
        uint li = 0;
        if(indices.length > 0) li = indices[indices.length-1]+1;
        indices ~= [li,li+1,li+2,li+2,li+1,li+3];
      }
    }
  }

  return Mesh!VertexPNT(vertices, indices);
}