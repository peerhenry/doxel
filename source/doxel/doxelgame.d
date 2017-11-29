module doxel.doxelgame;

import std.stdio;

import gfm.opengl, gfm.math;

import engine;

import doxel.cube, vertex, model, modelsetter, pvm_normalmatrix_setter;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Model!VertexPN model;
  OpenGL gl;
  VertexSpecification!VertexPN vertexSpec;

  this(OpenGL gl, Camera camera)
  {
    this.gl = gl;
    this.camera = camera;
    this.createProgram();
  }

  ~this()
  {
    this.program.destroy;
    this.vertexSpec.destroy;
    this.model.destroy;
  }

  /// Creates a shader program 
  void createProgram()
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/standard.glsl");
    this.program = new GLProgram(gl, shader_source);
    this.vertexSpec = new VertexSpecification!VertexPN(this.program);
  }

  void initialize()
  {
    Cube cube = new Cube();
    VertexPN[24] vertexArray;
    ModelSetter modelSetter = new PvmNormalMatrixSetter(this.program, this.camera);
    foreach(i; 0..24)
    {
      const int offset = 3*i;

      const float x = cube.positions[offset + 0];
      const float y = cube.positions[offset + 1];
      const float z = cube.positions[offset + 2];

      const float n_x = cube.normals[offset + 0];
      const float n_y = cube.normals[offset + 1];
      const float n_z = cube.normals[offset + 2];

      vertexArray[i] = VertexPN(vec3f(x, y, z), vec3f(n_x, n_y, n_z));
    }
    this.model = new Model!VertexPN(gl, modelSetter, this.vertexSpec, vertexArray, cube.indices);
    setGlSettings();

    this.program.uniform("LightDirection").set( vec3f(-0.8, 0.0, 1.0).normalized() );
    this.program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    this.program.uniform("AmbientColor").set( vec3f(0.0, 0.0, 0.0) );
    this.program.uniform("MaterialColor").set( vec3f(0.7, 0.2, 0.1) );
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW); // clockwise faces are front*/
    glClearColor(100.0/255, 149.0/255, 237.0/255, 1.0); // cornflower blue
  }

  void update()
  {
    
  }

  void draw()
  {
    mat4f modelMatrix = this.model.modelMatrix;
    mat3f normalMatrix = cast(mat3f)modelMatrix;
    mat4f pvm = this.camera.projection * this.camera.view * modelMatrix;
    this.program.uniform("PVM").set( pvm );
    this.program.uniform("NormalMatrix").set( normalMatrix );

    this.program.use();

    this.model.draw();

    program.unuse();
  }
}