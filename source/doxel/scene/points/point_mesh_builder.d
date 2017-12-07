import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures;

class PointMeshBuilder : IChunkMeshBuilder!VertexPC
{
  World world;

  this(World world)
  {
    this.world = world;
  }

  Mesh!VertexPC buildChunkMesh(Chunk chunk)
  {
    VertexPC[] vertices;
    updateMeshData(chunk, vec3f(0,0,0), vertices);
    return Mesh!VertexPC(vertices, []);
  }

  Mesh!VertexPC buildChunkMesh(Chunk[] chunks, Chunk originChunk)
  {
    VertexPC[] vertices;
    foreach(chunk; chunks)
    {
      vec3f offset = chunk.getPositionRelativeTo(originChunk);
      updateMeshData(chunk, offset, vertices);
    }
    return Mesh!VertexPC(vertices, []);
  }

  private void updateMeshData(Chunk chunk, vec3f vertexOffset, ref VertexPC[] vertices)
  {
    foreach(int i, block; chunk.blocks)
    {
      bool shouldAddBlock = false;
      if(block == Block.EMPTY) continue;
      vec3i site = SiteCalculator.siteIndexToSite(i);
      foreach(sd; allSides) // sd is short for SideDetails
      {
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

        if(adjBlock == Block.EMPTY)
        {
          vec3f position = site + vec3f(0.5, 0.5, 0.5) + vertexOffset;
          vec3f color = getColor(block);
          vertices ~= VertexPC(position, color);
          break;
        }
      }
    }
  }

  private vec3f getColor(Block block)
  {
    final switch(block)
    {
      case Block.EMPTY:
        return vec3f(0,0,0);
      case Block.GRASS:
        return vec3f(0,0.8,0);
      case Block.STONE:
        return vec3f(0.6,0.5,0.4);
      case Block.DIRT:
        return vec3f(0.6,0.4,0.1);
      case Block.SAND:
        return vec3f(0.9,0.9,0.2);
      case Block.TRUNK:
        return vec3f(0.6,0.4,0.1);
      case Block.LEAVES:
        return vec3f(0,0.7,0);
      case Block.WATER:
        return vec3f(0.5,0.6,0.95);
    }
  }
}