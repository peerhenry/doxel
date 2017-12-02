class Limiter
{
  private int limit;
  private int counter;

  this(int limit)
  {
    this.limit = limit;
  }

  void reset()
  {
    counter = 0;
  }

  void increment()
  {
    counter++;
  }

  bool limitReached()
  {
    return counter == limit;
  }
}