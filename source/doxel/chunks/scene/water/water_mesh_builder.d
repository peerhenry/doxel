import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures;

class WaterMeshBuilder : IChunkMeshBuilder!VertexP
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

  Mesh!VertexP buildChunkMesh(Chunk chunk)
  {
    VertexP[] vertices;
    uint[] indices;
    updateMeshData(chunk, vec3f(0,0,0), vertices, indices);
    return Mesh!VertexP(vertices, indices);
  }

  Mesh!VertexP buildChunkMesh(Chunk[] chunks, Chunk originChunk)
  {
    VertexP[] vertices;
    uint[] indices;
    foreach(chunk; chunks)
    {
      vec3f offset = chunk.getPositionRelativeTo(originChunk);
      if(chunk.hasAnyVisisbleBlocks) updateMeshData(chunk, offset, vertices, indices);
    }
    return Mesh!VertexP(vertices, indices);
  }

  private Block getAdjacentBlock(Chunk chunk, vec3i site, SideDetails sideDetails)
  {
    vec3i adjSite = site + cast(vec3i)sideDetails.normal;
    bool withinBounds = !calculator.isOutOfBounds(adjSite);
    Block adjBlock = Block.EMPTY;
    if(withinBounds) adjBlock = chunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
    else
    {
      IChunk adjChunk = world.getAdjacentChunk(chunk, sideDetails);
      if(adjChunk !is null)
      {
        if(adjChunk.isPulp())
        {
          adjBlock = Block.PULP;
        }
        adjSite = SiteCalculator.siteModulo(adjSite);
        adjBlock = adjChunk.getBlock(adjSite.x, adjSite.y, adjSite.z);
      }
    }
    return adjBlock;
  }

  private void updateMeshData(Chunk chunk, vec3f vertexOffset, ref VertexP[] vertices, ref uint[] indices)
  {
    float heightLevel = 0;
    bool addQuad = false;
    foreach(int i, block; chunk.blocks)
    {
      vec3i site = SiteCalculator.siteIndexToSite(i);
      if(block != Block.WATER) continue;
      if(getAdjacentBlock(chunk, site, TopDetails) == Block.EMPTY){
        heightLevel = site.z + 0.8;
        addQuad = true;
        break;
      }
    }
    if(!addQuad) return;
    vertices ~= [
        VertexP(vertexOffset + vec3f(0, 0, heightLevel)) // 00
      , VertexP(vertexOffset + vec3f(0, regionLength, heightLevel)) //0l
      , VertexP(vertexOffset + vec3f(regionWidth, 0, heightLevel)) //w0
      , VertexP(vertexOffset + vec3f(regionWidth, regionLength, heightLevel)) //wl
    ];
    uint li = 0;
    if(indices.length > 0) li = indices[indices.length-1]+1;
    indices ~= [li,li+1,li+2,li+2,li+1,li+3];
  }
}