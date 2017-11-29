import std.typecons;

import gfm.math, gfm.opengl;

import vertex, modelsetter;

/// An indexed vertex model
class Model(VertexType)
{
  private
  {
    GLBuffer vbo;
    GLBuffer ibo;
    GLVAO vao;
    GLuint indexCount;
    ModelSetter modelSetter;
  }
  mat4f modelMatrix;

  /// constructor
  this(OpenGL gl, ModelSetter modelSetter, VertexSpecification!VertexType spec, VertexType[] vertices, GLuint[] indices)
  {
    this.modelSetter = modelSetter;
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
    this.modelMatrix = mat4f.identity;
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
    this.modelSetter.set(this.modelMatrix);
    this.vao.bind();
    glDrawElements(
        GL_TRIANGLES,      // mode
        this.indexCount,   // count
        GL_UNSIGNED_INT,   // type
        null               // offset
    );
    this.vao.unbind();
  }
}