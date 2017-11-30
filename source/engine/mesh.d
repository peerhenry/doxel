import gfm.opengl;

struct Mesh(VertexType)
{
  VertexType[] vertices;
  GLuint[] indices;
}