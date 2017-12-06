import std.typecons;

import gfm.math, gfm.opengl;

import vertex, mesh, engine.interfaces;

/// An indexed vertex model
class Model(VertexType) : Drawable
{
  private
  {
    GLBuffer vbo;
    GLBuffer ibo;
    GLVAO vao;
    GLuint indexCount;
  }

  /// constructor
  this(
    OpenGL gl, // for buffer creation
    VertexSpecification!VertexType spec, // for creating the VAO
    Mesh!VertexType mesh)
  {
    vbo = new GLBuffer(gl, GL_ARRAY_BUFFER, GL_STATIC_DRAW);
    vbo.setData(mesh.vertices);
    ibo = new GLBuffer(gl, GL_ELEMENT_ARRAY_BUFFER, GL_STATIC_DRAW);
    ibo.setData(mesh.indices);
    this.indexCount = cast(uint)mesh.indices.length;
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

  /// Binds the VAO and calls glDrawElements
  void draw()
  {
    this.vao.bind();
    glDrawElements(
        GL_TRIANGLES,      // mode
        this.indexCount,   // count
        GL_UNSIGNED_INT,   // type
        null               // offset
    );
    this.vao.unbind();
  }

  GLVAO getVAO()
  {
    return vao;
  }
}