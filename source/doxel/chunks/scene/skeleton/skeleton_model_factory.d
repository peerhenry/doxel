import gfm.opengl, gfm.math;
import engine;
import doxel_world, doxel_scene;

class SkeletonModelFactory : IChunkModelFactory
{
  private
  {
    OpenGL gl;
    VertexSpecification!VertexP spec;
    IChunkMeshBuilder!VertexP meshBuilder;
  }

  this(OpenGL gl, VertexSpecification!VertexP spec, IChunkMeshBuilder!VertexP meshBuilder)
  {
    this.gl = gl;
    this.spec = spec;
    this.meshBuilder = meshBuilder;
  }

  Drawable createModel(Chunk chunk)
  {
    Mesh!VertexP mesh = meshBuilder.buildChunkMesh(chunk);
    if(mesh.vertices.length == 0)
    {
      return new DefaultDraw();
    }
    else return new Model!VertexP(gl, spec, mesh);
  }

  /// create model from multiple chunks, relative to one chunk
  Drawable createModel(Chunk[] chunks, Chunk originChunk)
  {
    assert(chunks.length > 0);
    Mesh!VertexP mesh = meshBuilder.buildChunkMesh(chunks, originChunk);
    assert(mesh.vertices.length > 0);
    VertexP[8] vertices;
    foreach(i, v; mesh.vertices)
    {
      vertices[i] = v;
    }
    return new HexaHedron(gl, spec, vertices);
  }
}