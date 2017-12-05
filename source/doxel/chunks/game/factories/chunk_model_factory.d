import gfm.opengl, gfm.math;
import engine;
import chunk_world, chunk_game;

class ChunkModelFactory : IChunkModelFactory
{
  private
  {
    OpenGL gl;
    VertexSpecification!VertexPNT spec;
    ChunkMeshBuilder meshBuilder;
  }

  this(OpenGL gl, VertexSpecification!VertexPNT spec, ChunkMeshBuilder meshBuilder)
  {
    this.gl = gl;
    this.spec = spec;
    this.meshBuilder = meshBuilder;
  }

  Drawable createModel(Chunk chunk)
  {
    Mesh!VertexPNT mesh = meshBuilder.buildChunkMesh(chunk);
    if(mesh.vertices.length == 0)
    {
      return new DefaultDraw();
    }
    else return new Model!VertexPNT(gl, spec, mesh);
  }

  /// create model from multiple chunks, relative to one chunk
  Drawable createModel(Chunk[] chunks, Chunk originChunk)
  {
    assert(chunks.length > 0);
    Mesh!VertexPNT mesh = meshBuilder.buildChunkMesh(chunks, originChunk);
    assert(mesh.vertices.length > 0);
    Model!VertexPNT model = new Model!VertexPNT(gl, spec, mesh);
    return model;
  }
}