import gfm.opengl, gfm.math;
import engine;
import doxel_world, doxel_scene;

class PointChunkModelFactory : IChunkModelFactory
{
  private
  {
    OpenGL gl;
    VertexSpecification!VertexPC spec;
    IChunkMeshBuilder!VertexPC meshBuilder;
  }

  this(OpenGL gl, VertexSpecification!VertexPC spec, IChunkMeshBuilder!VertexPC meshBuilder)
  {
    this.gl = gl;
    this.spec = spec;
    this.meshBuilder = meshBuilder;
  }

  Drawable createModel(Chunk chunk)
  {
    Mesh!VertexPC mesh = meshBuilder.buildChunkMesh(chunk);
    if(mesh.vertices.length == 0)
    {
      return new DefaultDraw();
    }
    else return new PointModel!VertexPC(gl, spec, mesh);
  }

  /// create model from multiple chunks, relative to one chunk
  Drawable createModel(Chunk[] chunks, Chunk originChunk)
  {
    assert(chunks.length > 0);
    Mesh!VertexPC mesh = meshBuilder.buildChunkMesh(chunks, originChunk);
    assert(mesh.vertices.length > 0);
    PointModel!VertexPC model = new PointModel!VertexPC(gl, spec, mesh);
    return model;
  }
}