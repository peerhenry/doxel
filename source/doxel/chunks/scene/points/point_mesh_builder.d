import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures, ichunk;

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
      if(chunk.hasAnyVisisbleBlocks) updateMeshData(chunk, offset, vertices);
    }
    return Mesh!VertexPC(vertices, []);
  }

  private void updateMeshData(Chunk chunk, vec3f vertexOffset, ref VertexPC[] vertices)
  {
    foreach(int i, block; chunk.blocks)
    {
      bool shouldAddBlock = false;
      if(block == Block.EMPTY || block == Block.PULP) continue;
      vec3i site = calculator.siteIndexToSite(i);
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
            adjSite = calculator.siteModulo(adjSite);
            adjBlock = adjChunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
          }
        }

        if(adjBlock == Block.EMPTY)
        {
          vec3f position = site + vec3f(0.5, 0.5, 0.5) + vertexOffset;
          vec3f color = getBlockColor(block);
          vertices ~= VertexPC(position, color);
          break;
        }
      }
    }
  }
}