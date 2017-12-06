/*import gfm.opengl, gfm.math;
import engine;
import chunk_game, limiter, chunk, world;
// obsolete: to be removed
class OldChunkScene
{
  private OpenGL gl;
  private Camera camera;
  private GLProgram program;
  private BaseChunkGameObject[] gameObjects;
  private VertexSpecification!VertexPNT spec;
  private Texture texture;

  private Limiter modelLimiter;
  private ChunkObjectFactory chunkObjFac;

  this(OpenGL gl, Camera camera, World world)
  {
    this.gl = gl;
    this.camera = camera;
    this.createProgram();
    this.texture = new Texture(gl, this.program, "Atlas", "resources/atlas.png"); // gl, program, shader uniform name, image path
    initUniforms();

    UniformSetter modelSetter = new PvmNormalMatrixSetter(this.program, this.camera, "PVM", "NormalMatrix"); // strings are uniform names in shader
    IChunkMeshBuilder meshBuilder = new ChunkMeshBuilder(world);
    ChunkModelFactory modelFactory = new ChunkModelFactory(gl, spec, meshBuilder);
    modelLimiter = new Limiter(12);
    chunkObjFac = new ChunkObjectFactory(this.camera, modelFactory, modelSetter, modelLimiter);
  }

  void createProgram()
  {
    // dispense with loading and compiling of individual shaders
    string[] shader_source = readLines("source/doxel/glsl/standard.glsl");
    program = new GLProgram(gl, shader_source);
    spec = new VertexSpecification!VertexPNT(program);
  }

  void initUniforms()
  {
    program.uniform("LightDirection").set( vec3f(0.8, -0.3, -1.0).normalized() );
    program.uniform("LightColor").set( vec3f(1.0, 1.0, 1.0) );
    program.uniform("AmbientColor").set( vec3f(0.4, 0.4, 0.4) );
    program.uniform("MaterialColor").set( vec3f(1, 1, 1) );
    program.uniform("PVM").set( mat4f.identity );
    program.uniform("NormalMatrix").set( mat3f.identity );
    texture.bind();
  }

  ~this()
  {
    program.destroy;
    spec.destroy;
    foreach(m; gameObjects)
    {
      m.destroy;
    }
    texture.destroy;
  }

  BaseChunkGameObject createChunkObject(Chunk[] chunks)
  {
    BaseChunkGameObject newObject = chunkObjFac.createChunkObject( chunks );
    gameObjects ~= newObject;
    return newObject;
  }

  void update(double dt_ms)
  {
    modelLimiter.reset();
    foreach(m; gameObjects)
    {
      m.update(dt_ms);
    }
  }

  void draw()
  {
    program.use();
    texture.bind();
    foreach(obj; gameObjects)
    {
      vec3f[8] boxCorners = obj.getBBCorners();
      if(camera.frustumContains(boxCorners) != frustum.OUTSIDE)
      {
        obj.draw();
      }
    }
    program.unuse();
  }
}*/