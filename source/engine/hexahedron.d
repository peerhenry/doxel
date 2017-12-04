import gfm.opengl;
import engine.interfaces, vertex;

class HexaHedron : Drawable
{
  GLBuffer vbo;
  GLBuffer ibo;
  GLVAO vao;
  uint indexCount;

  this(
    OpenGL gl, // for buffer creation
    VertexSpecification!VertexP spec, // for creating the VAO
    VertexP[8] vertices)
  {
    vbo = new GLBuffer(gl, GL_ARRAY_BUFFER, GL_STATIC_DRAW);
    vbo.setData(vertices);
    ibo = new GLBuffer(gl, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW);
    ibo.setData(indices);
    this.indexCount = cast(uint)indices.length;
    this.vao = new GLVAO(gl);
    {
      this.vao.bind();
      vbo.bind();
      spec.use();
      ibo.bind();
      this.vao.unbind();
    }
  }

  ~this()
  {
    this.vao.destroy;
    this.vbo.destroy;
    this.ibo.destroy;
  }

  void draw()
  {
    this.vao.bind();
    glDrawElements(GL_LINES, indexCount, GL_UNSIGNED_SHORT, null);
    this.vao.unbind();
  }

  // data
  static ushort[] indices = [
    0,1, 0,2, 0,4,
    3,1, 3,2, 3,7,
    5,1, 5,4, 5,7,
    6,2, 6,4, 6,7
  ];
}