import std.math;
import gfm.math;

import updatable;

class Camera : Updatable
{
  private:
  // matrices
  mat4f m_proj;
  mat4f m_view;
  
  vec3f pos;
  float theta;
  float phi;
  vec3f dir;
  vec3f right;
  vec3f relup;
  vec3f target;

  float FOVY;
  float ratio;
  float near;
  float far;
  float near_height;
  float near_width;

  bool updateView;
  // matrix calculations
  void calculateTargetAndView()
  {
    float sint = sin(theta);
    float cost = cos(theta);
    float cosp = cos(phi);
    float sinp = sin(phi);    
    this.dir = vec3f(cost*cosp, sint*cosp, sinp);
    this.right = vec3f(sint, -cost, 0);
    this.relup = vec3f(-cost*sinp, -sint*sinp, cosp);
    this.target = this.pos + this.dir;
    calculateView();
  }

  void calculateView()
  {
    this.m_view = mat4f.lookAt(pos, target, up);
  }

  void calculateProjection()
  {
    this.m_proj = mat4f.perspective(this.FOVY, this.ratio, this.near, this.far);
    this.near_height = 2*near*tan(this.FOVY/2);
    this.near_width = this.near_height*this.ratio;
  }

  public:
  
  static const vec3f up = vec3f(0.0, 0.0, 1.0);

  this()
  {
    this.FOVY = PI / 3;
    this.ratio = 16.0/9.0;
    this.near = 0.1;
    this.far = 99999.0;
    calculateProjection();
	  this.pos = vec3f(-10.0, 0, 0);
    this.theta = 0.0;
    this.phi = 0.0;
    calculateTargetAndView();
  }

  void preUpdate()
  {
    updateView = false;
  }

  void update()
  {
    if(updateView) calculateTargetAndView();
  }

  // SETTERS

  void setFovy(float fovy)
  {
    this.FOVY = fovy;
    calculateProjection();
  }

  void setNearFar(float near, float far)
  {
    this.near = near;
    this.far = far;
    calculateProjection();
  }

  void setRatio(float ratio)
  {
    this.ratio = ratio;
    calculateProjection();
  }

  void translate(vec3f ds)
  {
    this.pos.xyz = this.pos.xyz + ds.xyz;
    updateView = true;
  }

  void setPosition(vec3f pos)
  {
    this.pos = pos;
    updateView = true;
  }

  void rotate(float dtheta, float  dphi)
  {
    this.theta += dtheta;
    this.phi += dphi;
    while(this.theta > 2*PI) this.theta -= 2*PI;
    while(this.theta < 0) this.theta += 2*PI;
    if(this.phi > PI_2) this.phi = PI_2;
    else if(this.phi < -PI_2) this.phi = -PI_2;
    updateView = true;
  }

  // GETTERS
  @property mat4f projection()
  {
    return m_proj;
  }

  @property mat4f view()
  {
    return m_view;
  }

  @property vec3f direction()
  {
    return dir;
  }

  @property vec3f directionRight()
  {
    return right;
  }

  @property vec3f position()
  {
    return pos;
  }

  float getTheta(){return theta;}
  float getPhi(){return phi;}

  alias Planef = Plane!float;

  vec3f[8] getFrustumCorners()
  {
    vec3f[8] output;

    vec3f nc = pos + near*dir;
    vec3f halfright = this.right*near_width*0.5;
    vec3f halfup = this.relup*near_height*0.5;
    output[0] = (nc - halfright - halfup); // near bottomleft
    output[1] = (nc - halfright + halfup); // near topleft
    output[2] = (nc + halfright - halfup); // near bottomright
    output[3] = (nc + halfright + halfup); // near topright

    vec3f fc = pos + far*dir;
    float fac = far/near;
    vec3f f_halfright = halfright*fac;
    vec3f f_halfup = halfup*fac;
    output[4] = (fc - f_halfright - f_halfup); // near bottomleft
    output[5] = (fc - f_halfright + f_halfup); // near topleft
    output[6] = (fc + f_halfright - f_halfup); // near bottomright
    output[7] = (fc + f_halfright + f_halfup); // near topright

    return output;
  }

  Frustum!float getFrustum()
  {
    vec3f nc = pos + near*dir;
    vec3f fc = pos + far*dir;
    Planef nearPlane = Planef(nc, dir);
    Planef farPlane = Planef(fc, -dir);

    vec3f halfright = this.right*near_width*0.5;
    vec3f r = (nc + halfright) - pos;
    r.normalize();
    vec3f normalRight = relup.cross(r);
    Planef rightPlane = Planef(pos, normalRight);

    vec3f l = (nc - halfright) - pos;
    l.normalize();
    vec3f normalLeft = l.cross(relup);
    Planef leftPlane = Planef(pos, normalLeft);

    vec3f halfup = this.relup*near_height*0.5;
    vec3f u = (nc + halfup) - pos;
    u.normalize();
    vec3f normalTop = u.cross(right);
    Planef topPlane = Planef(pos, normalTop);

    vec3f b = (nc - halfup) - pos;
    b.normalize();
    vec3f normalBottom = right.cross(b);
    Planef bottomPlane = Planef(pos, normalBottom);

    // left, right, top, bottom, near, far
    return Frustum!float(leftPlane, rightPlane, topPlane, bottomPlane, nearPlane, farPlane);
  }

  int contains(Frustum!float frustum, vec3f[8] boxCorners) pure const nothrow
  {
    int totalIn = 0;
    // test all 8 corners against the 6 sides
    // if all points are behind 1 specific plane, we are out
    // if we are in with all points, then we are fully in
    for(int p = 0; p < 6; ++p)
    {
      int inCount = 8;
      int ptIn = 1;

      for(int i = 0; i < 8; ++i)
      {
        // test this point against the planes
        if (frustum.planes[p].isBack(boxCorners[i]))
        {
          ptIn = 0;
          --inCount;
        }
      }

      // were all the points outside of plane p?
      if (inCount == 0)
        return frustum.OUTSIDE;

      // check if they were all on the right side of the plane
      totalIn += ptIn;
    }

    // so if totalIn is 6, then all are inside the view
    if(totalIn == 6)
      return frustum.INSIDE;

    // we must be partly in then otherwise
    return frustum.INTERSECT;
  }
}