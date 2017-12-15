import gfm.math;
import engine;
import i_chunk_mesh_builder, doxel_world, quadbuilder_pnt, sides, block_textures;

class SkeletonMeshBuilder : IChunkMeshBuilder!VertexP
{
  Mesh!VertexP buildChunkMesh(Chunk chunk)
  {
    return buildChunkMesh([chunk], chunk);
  }

  Mesh!VertexP buildChunkMesh(Chunk[] chunks, Chunk originChunk)
  {
    VertexP[8] vertices;
    float minx = 999999;
    float miny = 999999;
    float minz = 999999;
    float maxx = -999999;
    float maxy = -999999;
    float maxz = -999999;
    foreach(chunk; chunks)
    {
      vec3f offset = chunk.getPositionRelativeTo(originChunk);
      if(offset.x < minx) minx = offset.x;
      if(offset.y < miny) miny = offset.y;
      if(offset.z < minz) minz = offset.z;
      if(offset.x + regionWidth > maxx) maxx = offset.x + regionWidth;
      if(offset.y + regionLength > maxy) maxy = offset.y + regionLength;
      if(offset.z + regionHeight > maxz) maxz = offset.z + regionHeight;
    }
    vertices[0] = VertexP(vec3f(minx, miny, minz));
    vertices[1] = VertexP(vec3f(minx, miny, maxz));
    vertices[2] = VertexP(vec3f(minx, maxy, minz));
    vertices[3] = VertexP(vec3f(minx, maxy, maxz));
    vertices[4] = VertexP(vec3f(maxx, miny, minz));
    vertices[5] = VertexP(vec3f(maxx, miny, maxz));
    vertices[6] = VertexP(vec3f(maxx, maxy, minz));
    vertices[7] = VertexP(vec3f(maxx, maxy, maxz));
    return Mesh!VertexP(vertices, []);
  }
}