import std.typecons;
import gfm.math, gfm.opengl;
import vertex, mesh, engine.interfaces;

/// An indexed vertex model
class PointModel(VertexType) : Drawable
{
  private
  {
    GLBuffer vbo;
    GLVAO vao;
    GLuint vertexCount;
    VertexSpecification!VertexType spec;
  }

  /// constructor
  this(
    OpenGL gl, // for buffer creation
    VertexSpecification!VertexType spec, // for creating the VAO
    Mesh!VertexType mesh)
  {
    vbo = new GLBuffer(gl, GL_ARRAY_BUFFER, GL_STATIC_DRAW);
    vbo.setData(mesh.vertices);
    this.vertexCount = cast(uint)mesh.vertices.length;
    this.spec = spec;
    this.vao = new GLVAO(gl);
    {
      this.vao.bind();
      vbo.bind();
      spec.use();
      this.vao.unbind();
    }
  }

  uint buff1;
  uint buff2;

  ~this()
  {
    this.vao.destroy;
    this.vbo.destroy;
  }

  /// Binds the VAO and calls glDrawElements
  void draw()
  {
    this.vao.bind();
    glDrawArrays(
        GL_POINTS,      // mode
        0,
        this.vertexCount,   // count
    );
    this.vao.unbind();
  }
}