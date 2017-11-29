import gfm.opengl;
import imageformats;

class Texture
{
  private GLProgram program;
  private string uniformName;
  private GLTexture2D tex;

  this(OpenGL gl, GLProgram program, string uniformName, string path)
  {
    this.program = program;
    this.uniformName = uniformName;
    IFImage img = read_image(path, ColFmt.RGB);
    this.tex = new GLTexture2D(gl);
    this.tex.setMinFilter(GL_NEAREST); // GL_LINEAR_MIPMAP_LINEAR
    this.tex.setMagFilter(GL_NEAREST); // GL_LINEAR
    this.tex.setWrapS(GL_REPEAT);
    this.tex.setWrapT(GL_REPEAT);
    this.tex.setImage(0, GL_RGB, img.w, img.h, 0, GL_RGB, GL_UNSIGNED_BYTE, img.pixels.ptr);
    this.tex.generateMipmap();
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