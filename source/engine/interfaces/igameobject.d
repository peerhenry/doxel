import gfm.math;
import engine.interfaces;

interface IGameObject: Drawable, Updatable
{
  Updatable getUpdateBehavior();

  Drawable getDrawBehavior();

  mat4f getModelMatrix();

  // setters

  void setUpdateBehavior(Updatable updatable);

  void setDrawBehavior(Drawable drawable);
}