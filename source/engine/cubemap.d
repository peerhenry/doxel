import gfm.opengl;
import imageformats;

class CubeMap
{
  private GLProgram program;
  private string uniformName;
  private GLTexture tex;

  /// Create cubemap from image files
  this(OpenGL gl, GLProgram program, string uniformName
    , string path_top
    , string path_bottom
    , string path_front
    , string path_back
    , string path_left 
    , string path_right)
  {
    import std.file;
    assert(exists(path_top));
    assert(exists(path_bottom));
    assert(exists(path_front));
    assert(exists(path_back));
    assert(exists(path_left));
    assert(exists(path_right));
    IFImage img_top = read_image(path_top, ColFmt.RGB);
    IFImage img_bottom = read_image(path_bottom, ColFmt.RGB);
    IFImage img_front = read_image(path_front, ColFmt.RGB);
    IFImage img_back = read_image(path_back, ColFmt.RGB);
    IFImage img_left = read_image(path_left, ColFmt.RGB);
    IFImage img_right = read_image(path_right, ColFmt.RGB);

  /// Create cubemap from data
  this(gl, program, uniformName, img_top.w, img_top.h, 
      img_top.pixels.ptr, img_bottom.pixels.ptr, img_front.pixels.ptr, img_back.pixels.ptr, img_left.pixels.ptr, img_right.pixels.ptr);
  }

    this(OpenGL gl, GLProgram program, string uniformName, uint w, uint h
    , const GLvoid * data_top
    , const GLvoid * data_bottom
    , const GLvoid * data_front
    , const GLvoid * data_back
    , const GLvoid * data_left 
    , const GLvoid * data_right)
  {
    this.program = program;
    this.uniformName = uniformName;
    this.tex = new GLTexture(gl, GL_TEXTURE_CUBE_MAP);
    this.tex.setMinFilter(GL_NEAREST); // GL_LINEAR_MIPMAP_LINEAR
    this.tex.setMagFilter(GL_NEAREST); // GL_LINEAR
    this.tex.setWrapS(GL_CLAMP_TO_EDGE);
    this.tex.setWrapT(GL_CLAMP_TO_EDGE);
    this.tex.setWrapR(GL_CLAMP_TO_EDGE);

    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_right);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_left);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Y, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_top);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_bottom);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_back);
    glTexImage2D(GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, 0, GL_RGB, w, h, 0, GL_RGB, GL_UNSIGNED_BYTE, data_front);
  }

  ~this()
  {
    this.tex.destroy;
  }

  void bind(){
    int texUnit = 0;
    tex.use(texUnit);
    program.uniform(uniformName).set(texUnit);
  }
}