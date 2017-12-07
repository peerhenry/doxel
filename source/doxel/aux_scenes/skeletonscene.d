import gfm.opengl, gfm.math;
import engine;

/*class SkeletonScene
{
  OpenGL gl;
  Camera cam;

  GLProgram program;
  VertexSpecification!VertexP spec;
  SceneObject[] sceneObjects;
  UniformSetter setter;

  this(OpenGL gl, Camera cam)
  {
    this.gl = gl;
    this.cam = cam;
    string[] shader_source = readLines("source/doxel/glsl/vertexposition.glsl");
    program = new GLProgram(gl, shader_source);
    spec = new VertexSpecification!VertexP(program);
    program.uniform("Color").set(vec3f(1,0,0));
    program.uniform("PVM").set(mat4f.identity);
    setter = new PvmSetter(program, cam, "PVM");
  }

  ~this()
  {
    this.program.destroy;
    spec.destroy;
    foreach(m; gameObjects)
    {
      m.destroy;
    }
  }

  void createCamFrustum()
  {
    vec3f[8] vecs = cam.getFrustumCorners();
    VertexP[8] vertices;
    foreach(i; 0..8) vertices[i] = VertexP(vecs[i]);
    createHexaHedron(vertices);
  }

  void createHexaHedron(VertexP[8] vertices)
  {
    Drawable draw = new HexaHedron(gl, spec, vertices);
    auto newObj = new GameObject(null, setter, draw, mat4f.identity);
    addGameObject(newObj);
  }

  void addGameObject(SceneObject sceneObject)
  {
    sceneObjects ~= sceneObject;
  }

  void update()
  {

  }

  void draw()
  {
    this.program.use();
    //Frustum!float frustum = camera.getFrustum(); // maybe move this to update?
    foreach(obj; gameObjects)
    {
      box3f box = obj.getBoundingBox();
      if(frustum.contains(box) == frustum.INSIDE)
      {
        obj.draw();
      }
    }
    program.unuse();
  }
}*/