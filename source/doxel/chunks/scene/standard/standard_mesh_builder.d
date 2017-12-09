import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures;

class StandardMeshBuilder : IChunkMeshBuilder!VertexPNT
{
  World world;

  this(World world)
  {
    this.world = world;
  }

  static bool isTranslucent(Block block)
  {
    if(block == Block.EMPTY) return true;
    if(block == Block.WATER) return true;
    return false;
  }

  int counter = 0;

  Mesh!VertexPNT buildChunkMesh(Chunk chunk)
  {
    VertexPNT[] vertices;
    uint[] indices;
    updateMeshData(chunk, vec3f(0,0,0), vertices, indices);
    return Mesh!VertexPNT(vertices, indices);
  }

  Mesh!VertexPNT buildChunkMesh(Chunk[] chunks, Chunk originChunk)
  {
    VertexPNT[] vertices;
    uint[] indices;
    foreach(chunk; chunks)
    {
      vec3f offset = chunk.getPositionRelativeTo(originChunk);
      if(chunk.hasAnyVisisbleBlocks) updateMeshData(chunk, offset, vertices, indices);
    }
    return Mesh!VertexPNT(vertices, indices);
  }

  private void updateMeshData(Chunk chunk, vec3f vertexOffset, ref VertexPNT[] vertices, ref uint[] indices)
  {
    /*import std.stdio, std.datetime;
    import std.datetime.stopwatch : benchmark, StopWatch;
    StopWatch sw;
    sw.start();*/

    foreach(int i, block; chunk.blocks)
    {
      //if(block == Block.EMPTY || block == Block.PULP) continue;
      if(block == Block.EMPTY) continue;
      vec3i site = SiteCalculator.siteIndexToSite(i);
      foreach(sd; allSides) // sd is short for SideDetails
      {
        vec3i adjSite = site + cast(vec3i)sd.normal;
        bool withinBounds = !calculator.isOutOfBounds(adjSite);
        Block adjBlock = Block.EMPTY;
        if(withinBounds) adjBlock = chunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
        else
        {
          IChunk adjChunk = world.getAdjacentChunk(chunk, sd);
          if(adjChunk !is null)
          {
            if(adjChunk.isPulp())
            {
              import std.stdio; writeln("pulp chunk detected in meshbuilder.");
              adjBlock = Block.PULP;
            }
            adjSite = SiteCalculator.siteModulo(adjSite);
            adjBlock = adjChunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
          }
        }

        bool shouldAddQuad = isTranslucent(block) ? adjBlock == Block.EMPTY : isTranslucent(adjBlock);

        if(shouldAddQuad)
        {
          vec3f quadCenter = (block == Block.WATER && sd.side == Side.Top) ? vec3f(0, 0, 0.85) : sd.normal;
          vec3f faceCenter = site + 0.5*(vec3f(1,1,1) + quadCenter) + vertexOffset;
          vertices ~= generateQuad(sd.side, faceCenter, getAtlasij(block, sd.side));
          uint li = 0;
          if(indices.length > 0) li = indices[indices.length-1]+1;
          indices ~= [li,li+1,li+2,li+2,li+1,li+3];
        }
      }
    }

    /*Duration dur = sw.peek();
    sw.stop();
    writeln("Chunk mesh build time: ", dur.toString());*/
  }
}