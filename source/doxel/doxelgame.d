import std.array;
import gfm.opengl, gfm.math, gfm.sdl2;
import engine;
import inputhandler, player,
    blocks, chunk_world, chunk_game, chunk_scene_world_generator,
    skybox, chunkscene, quadoverlay, skeletonscene;

class DoxelGame : Game
{
  GLProgram program;
  Camera camera;
  Player player;
  OpenGL gl;
  InputHandler input;

  World world;

  Skybox skybox;
  ChunkScene chunkScene;
  SkeletonScene skeletonScene;
  ChunkSceneWorldGenerator generator;

  SDLTTF ttf;
  SDLFont font;
  SDL2Surface surface;
  SDL2Texture sdlTexture;
  SDL2Renderer renderer;

  QuadOverlay quadModel;

  this(Context context, InputHandler input, Camera camera, Player player)
  {
    this.gl = context.gl;
    this.input = input;
    input.setGame(this);
    this.camera = camera;
    this.player = player;
    camera.setPosition(vec3f(0,0,10));

    World world = new World();

    // create scenes
    skybox = new Skybox(gl, camera);
    chunkScene = new ChunkScene(gl, camera, world);
    skeletonScene = new SkeletonScene(gl, camera);

    generator = new ChunkSceneWorldGenerator(camera, world, chunkScene);

    // load font
    /*this.ttf = new SDLTTF(context.sdl);
    this.font = new SDLFont(this.ttf, "resources/fonts/consola.ttf", 14);
    this.surface = this.font.renderTextSolid("HIHAHO YOYOYOYOYOYO", SDL_Color(0,0,0,255));
    this.renderer = new SDL2Renderer(surface);
    this.sdlTexture = new SDL2Texture(renderer, surface);
    this.surface.destroy;
    this.font.destroy;*/

    //this.quadModel = new QuadOverlay(gl);
  }

  ~this()
  {
    chunkScene.destroy;
    skybox.destroy;
    skeletonScene.destroy;

    /*this.ttf.destroy;
    this.renderer.destroy;
    this.sdlTexture.destroy;
    //this.surface.destroy;
    //this.font.destroy;*/
  }

  void initialize()
  {
    setGlSettings();
  }

  void setGlSettings()
  {
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    glFrontFace(GL_CW); // clockwise faces are front
    glClearColor(100.0/255, 149.0/255, 237.0/255, 1.0); // cornflower blue
  }

  void clickRemoveBlock()
  {
    vec3f campos = camera.position;
    vec3f camdir = camera.direction;
    // calculate line intersection with chunk, and then with block
  }

  void update(double dt_ms)
  {
    input.update();
    camera.update(dt_ms);
    player.update(dt_ms);
    generator.update(dt_ms);
    chunkScene.update(dt_ms);
  }
  
  void draw()
  {
    skybox.draw();
    chunkScene.draw();
    skeletonScene.draw();

    /*renderer.clear();
    renderer.copy(sdlTexture, 10, 10);
    renderer.present();*/
    
    //glBindTexture(GL_TEXTURE_2D, sdlTexture.access());
    //glColor3f(1, 0, 0);
    //quadModel.draw(); 
  }
}