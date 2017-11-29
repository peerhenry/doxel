import core.thread;

import gfm.logger,
       gfm.sdl2,
       gfm.opengl;

import engine.interfaces;

class Context
{
  SDL2 sdl;
  OpenGL gl;
  SDL2Window window;

  this(int width, int height, string name)
  {
    // create a coloured console logger
    auto log = new ConsoleLogger();

    // load dynamic libraries
    this.sdl = new SDL2(log, SharedLibVersion(2, 0, 0));

    this.gl = new OpenGL(log);

    // You have to initialize each SDL subsystem you want by hand
    sdl.subSystemInit(SDL_INIT_VIDEO);
    sdl.subSystemInit(SDL_INIT_EVENTS);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // create an OpenGL-enabled SDL window
    this.window = new SDL2Window(sdl,
                                SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED,
                                width, height,
                                SDL_WINDOW_OPENGL);
    this.window.setTitle(name);

    // Reload OpenGL now that a context exists
    // Always provide a maximum version else the maximum known 
    // OpenGL 4.5 may be loaded and you risk hitting missing
    // functions bugs from drivers.
    this.gl.reload( GLVersion.None, GLVersion.GL33 );

    // redirect OpenGL output to our Logger
    this.gl.redirectDebugOutput();
  }

  ~this()
  {
    sdl.destroy;
    gl.destroy;
    window.destroy;
  }

  void run(Game game)
  {
    game.initialize();
    double time = 0;
    uint lastTime = SDL_GetTicks();
    bool shouldQuit;
    while(!shouldQuit)
    {
      sdl.processEvents();

      uint now = SDL_GetTicks();
      double dt = now - lastTime;
      lastTime = now;
      time += 0.001 * dt;

      // update
      game.update();

      glViewport(0, 0, window.getWidth(), window.getHeight());
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      // render
      game.draw();
      
      window.swapBuffers();

      shouldQuit = sdl.keyboard.isPressed(SDLK_ESCAPE);
      Thread.sleep( dur!("msecs")( 16 ) );
    }
  }
}