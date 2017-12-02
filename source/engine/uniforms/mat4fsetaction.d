import gfm.math;
import engine.interfaces;
class Mat4fSetAction : UniformSetAction
{
  UniformSetter!mat4f setter;
  mat4f value;

  this(UniformSetter!mat4f setter, mat4f value)
  {
    this.setter = setter;
    this.value = value;
  }

  void setUniforms()
  {
    setter.setUniform(value);
  }
}