import engine.interfaces;

class GameObject : Updatable, Drawable
{
  Updatable updateBehavior;
  UniformSetAction uniformSetBehavior;
  Drawable drawBehavior;

  this(Updatable updateBehavior, UniformSetAction uniformSetBehavior, Drawable drawBehavior)
  {
    if(updateBehavior is null) this.updateBehavior = new DefaultUpdate();
    else this.updateBehavior = updateBehavior;
    this.uniformSetBehavior = uniformSetBehavior;
    if(drawBehavior is null) this.drawBehavior = new DefaultDraw();
    else this.drawBehavior = drawBehavior;
  }

  this(UniformSetAction uniformSetBehavior, Drawable drawBehavior)
  {
    this(null, uniformSetBehavior, drawBehavior);
  }

  void update()
  {
    this.updateBehavior.update();
  }

  void draw()
  {
    this.uniformSetBehavior.setUniforms();
    this.drawBehavior.draw();
  }
}