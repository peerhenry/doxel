import gfm.opengl, gfm.math;
import engine;
import ichunkmodelfactory, chunk, chunkmeshbuilder;

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

  ChunkModel createModel(Chunk chunk)
  {
    Mesh!VertexPNT mesh = meshBuilder.buildChunkMesh(chunk);
    Model!VertexPNT model = new Model!VertexPNT(gl, spec, mesh);
    return model;
  }
}