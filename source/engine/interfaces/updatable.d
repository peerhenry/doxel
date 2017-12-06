interface Updatable
{
  void update(double dt_ms);
}

class DefaultUpdate : Updatable
{
  void update(double dt_ms){};
}