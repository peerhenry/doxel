class Limiter
{
  private int _limit;
  @property int limit(){ return _limit; }
  private int _counter;

  this(int limit)
  {
    this._limit = limit;
  }

  void reset()
  {
    _counter = 0;
  }

  void increment()
  {
    _counter++;
  }

  bool limitReached()
  {
    return _counter >= _limit;
  }
}