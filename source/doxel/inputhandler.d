import gfm.math, gfm.sdl2;
import engine;
import doxelgame;

class InputHandler
{
  private
  {
    SDL2 sdl;
    int prev_x;
    int prev_y;
    Camera cam;
    DoxelGame game;
  }

  this(Context context, Camera cam)
  {
    this.sdl = context.sdl;
    this.cam = cam;
    this.sdl.mouse.startCapture();
    SDL_SetRelativeMouseMode(true);
  }

  void setGame(DoxelGame game)
  {
    this.game = game;
  }

  void update()
  {
    updateMouse();
    updateKeys();
  }

  void updateMouse()
  {
    updateMouseMovement();
    updateMouseClicks();
  }

  void updateMouseMovement()
  {
    int new_x = sdl.mouse.x;
    int new_y = sdl.mouse.y;
    int dx = 0;
    int dy = 0;
    bool rotate = false;
    if(new_x != prev_x)
    {
      dx = sdl.mouse.lastDeltaX;
      rotate = true;
    }
    if(new_y != prev_y)
    {
      dy = sdl.mouse.lastDeltaY;
      rotate = true;
    }
    if(rotate)
    {
      float dtheta = -cast(float)(dx)*0.005;
      float dphi = -cast(float)(dy)*0.005;
      cam.rotate(dtheta, dphi);
    }
    this.prev_x = new_x;
    this.prev_y = new_y;
  }

  void updateMouseClicks()
  {
    // Check if the left mouse button is pressed
    if(sdl.mouse.isButtonPressed(SDL_BUTTON_LMASK))
    {
      // cast ray into world, collide with chunk, collide with cube, remove cube
      game.clickRemoveBlock();
    }
  }

  void updateKeys()
  {
    bool f = sdl.keyboard.isPressed(SDLK_a);
    bool b = sdl.keyboard.isPressed(SDLK_z);
    bool l = sdl.keyboard.isPressed(SDLK_s);
    bool r = sdl.keyboard.isPressed(SDLK_d);
    bool u = sdl.keyboard.isPressed(SDLK_SPACE);
    bool d = sdl.keyboard.isPressed(SDLK_LCTRL);
    vec3f movedir = vec3f(0,0,0);
    float ds = 0.5;
    if(f)
    {
      movedir += cam.direction;
    }
    else if(b)
    {
      movedir -= cam.direction;
    }

    if(l)
    {
      movedir -= cam.direction.cross(cam.up);
    }
    else if(r)
    {
      movedir += cam.direction.cross(cam.up);
    }

    if(u)
    {
      movedir += cam.up;
    }
    else if(d)
    {
      movedir -= cam.up;
    }

    if(f || b || l || r || u || d)
    {
      vec3f dvec = movedir.normalized()*ds;
      cam.translate(dvec);
    }
  }
}