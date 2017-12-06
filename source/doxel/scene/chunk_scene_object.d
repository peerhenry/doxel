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
  }

  @property mat4f modelMatrix() { return _modelMatrix; }

  this(UniformSetter setter, mat4f modelMatrix, Drawable drawBehavior, vec3f min, vec3f max)
  {
    this.setter = setter;
    this._modelMatrix = modelMatrix;
    this.drawBehavior = drawBehavior;
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