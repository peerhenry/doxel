public import drawable;
public import updatable;

interface Game : Updatable, Drawable
{
  void initialize();
}