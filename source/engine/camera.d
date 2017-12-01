import std.math;
import gfm.math;

import updatable;

class Camera : Updatable
{
  private:
  // matrices
  mat4f m_proj;
  mat4f m_view;
  // matrix derivatives
  vec3f pos;
  float theta;
  float phi;
  vec3f dir;
  vec3f target;
  float ratio;
  float near;
  float far;
  bool updateView;
  // matrix calculations
  void calculateTargetAndView()
  {
    this.dir = vec3f(cos(theta)*cos(phi), sin(theta)*cos(phi), sin(phi));
    this.target = this.pos + this.dir;
    calculateView();
  }
  void calculateView()
  {
    this.m_view = mat4f.lookAt(this.pos, target, up);
  }
  void calculateProjection()
  {
    this.m_proj = mat4f.perspective(PI / 3, this.ratio, this.near, this.far);
  }

  public:
  
  static immutable vec3f up = vec3f(0.0, 0.0, 1.0);

  this()
  {
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

  @property vec3f position()
  {
    return pos;
  }
}