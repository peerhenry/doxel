import gfm.opengl;

class QuadOverlay
{
  GLBuffer vbo;
  
  this(OpenGL gl)
  {
    this.vbo = new GLBuffer(gl, GL_ARRAY_BUFFER, GL_STATIC_DRAW);
    vbo.setData(quadVertices);
  }

  ~this()
  {
    this.vbo.destroy;
  }

  void draw()
  {
    //glDisable(GL_DEPTH_TEST);
    //glColor3f(1,0,0);
    /*this.vbo.bind();
    glVertexPointer(3, GL_FLOAT, 0, null);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDisableClientState(GL_VERTEX_ARRAY);*/
    /*glBegin(GL_QUADS);                      // Draw A Quad
      glVertex3f(-1.0f, 1.0f, 0.0f);              // Top Left
      glVertex3f( 1.0f, 1.0f, 0.0f);              // Top Right
      glVertex3f( 1.0f,-1.0f, 0.0f);              // Bottom Right
      glVertex3f(-1.0f,-1.0f, 0.0f);              // Bottom Left
    glEnd();*/
    //glEnable(GL_DEPTH_TEST);
  }

  // data

  GLfloat[] quadVertices = [
    -1.0f, 1.0f, 0.0f, 
    1.0f, 1.0f, 0.0f, 
    1.0f,-1.0f, 0.0f,
    -1.0f,-1.0f, 0.0f
  ];

  uint[] indices = [0,1,2,2,3,0];
}