import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures;

class WaterMeshBuilder : IChunkMeshBuilder!VertexPT
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

  Mesh!VertexPT buildChunkMesh(Chunk chunk)
  {
    VertexPT[] vertices;
    uint[] indices;
    updateMeshData(chunk, vec3f(0,0,0), vertices, indices);
    return Mesh!VertexPT(vertices, indices);
  }

  Mesh!VertexPT buildChunkMesh(Chunk[] chunks, Chunk originChunk)
  {
    VertexPT[] vertices;
    uint[] indices;
    foreach(chunk; chunks)
    {
      vec3f offset = chunk.getPositionRelativeTo(originChunk);
      if(chunk.hasAnyVisisbleBlocks) updateMeshData(chunk, offset, vertices, indices);
    }
    return Mesh!VertexPT(vertices, indices);
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

  private void updateMeshData(Chunk chunk, vec3f vertexOffset, ref VertexPT[] vertices, ref uint[] indices)
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
        VertexPT(vertexOffset + vec3f(0, 0, heightLevel), vec2f(0,0)) // 00
      , VertexPT(vertexOffset + vec3f(0, regionLength, heightLevel), vec2f(0,1)) //0l
      , VertexPT(vertexOffset + vec3f(regionWidth, 0, heightLevel), vec2f(1,0)) //w0
      , VertexPT(vertexOffset + vec3f(regionWidth, regionLength, heightLevel), vec2f(1,1)) //wl
    ];
    uint li = 0;
    if(indices.length > 0) li = indices[indices.length-1]+1;
    indices ~= [li,li+1,li+2,li+2,li+1,li+3];
  }
}