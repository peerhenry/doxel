import gfm.opengl;
import engine;
import chunk;
class ChunkModel : Model!VertexPNT
{
  private Chunk chunk;

  this(OpenGL gl, // for buffer creation
    ModelSetter setter, // for uploading the model matrix
    VertexSpecification!VertexPNT spec, // for creating the VAO
    Mesh!VertexPNT mesh,
    Chunk chunk)
  {
    super(gl, setter, spec, mesh);
    this.chunk = chunk;
  }
}