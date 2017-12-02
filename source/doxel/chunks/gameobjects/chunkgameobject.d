import gfm.math;
import engine;
import chunk;
class ChunkGameObject : GameObject
{
  Chunk chunk;

  this(Updatable updateBehavior, UniformSetter uniformSetBehavior, Drawable drawBehavior, mat4f modelMatrix)
  {
    super(updateBehavior, uniformSetBehavior, drawBehavior, modelMatrix);
  }

  override void draw()
  {
    super.draw();
  }
}