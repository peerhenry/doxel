import gfm.opengl;

struct Mesh(VertexType)
{
  private VertexType[] _vertices;
  @property VertexType[] vertices(){return _vertices;}

  private GLuint[] _indices;
  @property GLuint[] indices(){return _indices;}

  this(VertexType[] vertices, GLuint[] indices)
  {
    _vertices = vertices;
    _indices = indices;
  }
}