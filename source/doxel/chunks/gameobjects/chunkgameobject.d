import engine;
import chunk;
class ChunkGameObject : GameObject
{
  Chunk chunk;

  this(Updatable updateBehavior, UniformSetAction uniformSetBehavior, Drawable drawBehavior)
  {
    super(updateBehavior, uniformSetBehavior, drawBehavior);
  }

  override void draw()
  {
    super.draw();
  }
}