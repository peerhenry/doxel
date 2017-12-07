import gfm.math;
import engine;
class ChunkSceneObject: SceneObject
{
  private{
    UniformSetter setter;
    mat4f _modelMatrix;
    Drawable drawBehavior;
    vec3f min;
    vec3f max;
    vec3f pos;
  }

  @property mat4f modelMatrix() { return _modelMatrix; }
  @property vec3f position() { return pos; }

  this(UniformSetter setter, mat4f modelMatrix, Drawable drawBehavior, vec3f min, vec3f max)
  {
    this.setter = setter;
    this._modelMatrix = modelMatrix;
    this.drawBehavior = drawBehavior;
    pos = (min+max)*0.5;
  }

  ~this()
  {
    drawBehavior.destroy;
  }

  void draw()
  {
    setter.setUniforms(this);
    drawBehavior.draw();
  }

  box3f getBoundingBox()
  {
    return box3f(min.x, max.x, min.y, max.y, min.z, max.z);
  }

  vec3f[8] getBBCorners()
  {
    return [
      vec3f(min.x, min.y, min.z),
      vec3f(min.x, min.y, max.z),
      vec3f(min.x, max.y, min.z),
      vec3f(min.x, max.y, max.z),
      vec3f(max.x, min.y, min.z),
      vec3f(max.x, min.y, max.z),
      vec3f(max.x, max.y, min.z),
      vec3f(max.x, max.y, max.z)
    ];
  }
}