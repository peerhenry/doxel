import gfm.math;
import engine;

class Player: Updatable
{
  Camera cam;
  float crownHeight;
  float camHeight;
  bool grounded;
  float speed = 7; // world float unit per second

  private float half_bb_w;
  private vec3f minOffset;
  private vec3f maxOffset;
  private vec3f velocity;
  private vec3f movedir;
  private bool isMoving;

  this(Camera cam, float height)
  {
    this.cam = cam;
    this.camHeight = height;
    crownHeight = 0.1*height;
    this.half_bb_w = camHeight/8;
    minOffset = vec3f(-half_bb_w, -half_bb_w, -camHeight);
    maxOffset = vec3f(half_bb_w, half_bb_w, camHeight);
    movedir = vec3f(0,0,0);
    grounded = true;
  }

  /// returns axially aligned bounding box
  box3f getAABB()
  {
    vec3f min = cam.position + vec3f(-half_bb_w, -half_bb_w, -camHeight);
    vec3f max = cam.position + vec3f(half_bb_w, half_bb_w, crownHeight);
    return box3f(min, max);
  }

  bool pointIsInBlock(vec3f point)
  {
    return false;
  }

  bool standsOnGround()
  {
    // todo; implement
    vec3f b1 = cam.position + vec3f(half_bb_w, half_bb_w, -camHeight - 0.01);
    if(pointIsInBlock(b1)) return true;
    vec3f b2 = cam.position + vec3f(half_bb_w, -half_bb_w, -camHeight - 0.01);
    if(pointIsInBlock(b2)) return true;
    vec3f b3 = cam.position + vec3f(-half_bb_w, half_bb_w, -camHeight - 0.01);
    if(pointIsInBlock(b3)) return true;
    vec3f b4 = cam.position + vec3f(-half_bb_w, -half_bb_w, -camHeight - 0.01);
    if(pointIsInBlock(b4)) return true;
    return false;
  }

  void move(byte moveByte)
  {
    movedir = vec3f(0,0,0);
    isMoving = false;
    bool f = (moveByte & 1) == 1;
    bool b = ((moveByte>>1) & 1) == 1;
    bool l = ((moveByte>>2) & 1) == 1;
    bool r = ((moveByte>>3) & 1) == 1;
    bool u = ((moveByte>>4) & 1) == 1;
    bool d = ((moveByte>>5) & 1) == 1;
    if(f)
    {
      movedir += vec3f(cam.direction.x, cam.direction.y, 0);
      if(!b) isMoving = true;
    }
    else if(b)
    {
      movedir -= vec3f(cam.direction.x, cam.direction.y, 0);
      isMoving = true;
    }

    if(l)
    {
      movedir -= cam.directionRight;
      if(!r) isMoving = true;
    }
    else if(r)
    {
      movedir += cam.directionRight;
      isMoving = true;
    }

    if(u)
    {
      movedir += vec3f(0,0,1);
      if(!d) isMoving = true;
    }
    else if(d)
    {
      movedir += vec3f(0,0,-1);
      isMoving = true;
    }

    if(isMoving)
    {
      movedir.fastNormalize();
    }
  }

  void update(double dt_ms)
  {
    if( grounded )
    {
      if( !standsOnGround() )
      {
        grounded = false;
      }
    }
    else
    {
      // fall
      velocity.z += 0.1*velocity.z;
    }
    vec3f move_velocity = vec3f(0,0,0);
    if( isMoving )
    {
      move_velocity = movedir*speed;
      vec3f ds = move_velocity*.1;
      cam.translate(ds);
    }
    /*if( isMoving || !grounded )
    {
      float dt = 20.0/1000;
      vec3f ds = (move_velocity + velocity)*dt;
      cam.translate(ds);
    }*/
  }
}