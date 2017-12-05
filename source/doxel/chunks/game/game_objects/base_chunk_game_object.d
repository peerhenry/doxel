import gfm.math;
import engine;
import uniformsetter;

abstract class BaseChunkGameObject: GameObject, IBoundingBoxContainer
{
  this(Updatable updateBehavior, UniformSetter uniformSetBehavior, Drawable drawBehavior, mat4f modelMatrix)
  {
    super(updateBehavior, uniformSetBehavior, drawBehavior, modelMatrix);
  }
}