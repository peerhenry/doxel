import gfm.math;
import engine.interfaces, model, vertex;

class GameObject : Updatable, Drawable
{
  Updatable updateBehavior;
  UniformSetter uniformSetBehavior;
  Drawable drawBehavior;
  mat4f modelMatrix;

  this(Updatable updateBehavior, UniformSetter uniformSetBehavior, Drawable drawBehavior, mat4f modelMatrix)
  {
    if(updateBehavior is null) this.updateBehavior = new DefaultUpdate();
    else this.updateBehavior = updateBehavior;
    this.uniformSetBehavior = uniformSetBehavior;
    if(drawBehavior is null) this.drawBehavior = new DefaultDraw();
    else this.drawBehavior = drawBehavior;
    this.modelMatrix = modelMatrix;
  }

  ~this()
  {
    if(updateBehavior !is null) updateBehavior.destroy();
    if(uniformSetBehavior !is null) uniformSetBehavior.destroy();
    if(drawBehavior !is null) // hack for proper shutdown
    {
      auto drawcast = cast(Model!VertexPNT)drawBehavior;
      if(drawcast !is null) drawcast.destroy();
    }
  }

  void update()
  {
    this.updateBehavior.update();
  }

  void draw()
  {
    this.uniformSetBehavior.setUniforms(this);
    this.drawBehavior.draw();
  }

  // getters

  Updatable getUpdateBehavior()
  {
    return updateBehavior;
  }

  Drawable getDrawBehavior()
  {
    return drawBehavior;
  }

  mat4f getModelMatrix()
  {
    return this.modelMatrix;
  }

  // setters

  void setUpdateBehavior(Updatable updatable)
  {
    this.updateBehavior = updatable;
  }

  void setDrawBehavior(Drawable drawable)
  {
    this.drawBehavior = drawable;
  }
}