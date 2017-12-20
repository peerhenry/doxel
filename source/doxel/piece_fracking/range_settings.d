import engine;

struct RangeSetting
{
  int rank;
  int loadRange;
  int unloadRange;
  int sqLoadRange;
  int sqUnloadRange;

  this(int rank, int loadRange, int unloadRange)
  {
    this.rank = rank;
    this.loadRange = loadRange;
    this.unloadRange = unloadRange;
    this.sqLoadRange = loadRange*loadRange;
    this.sqUnloadRange = unloadRange * unloadRange;
  }
}

class RangeSettings
{
  private int _maxRank;
  @property int maxRank(){ return _maxRank; }
  private RangeSetting[] _settings;
  private RangeSetting _lowestRankRange;
  private RangeSetting _topRankRange;
  @property RangeSetting topRankRange() { return _topRankRange; }

  this(RangeSetting[] settings)
  {
    _maxRank = 0;
    _settings = settings;
    _lowestRankRange = settings[0];
    foreach(setting; settings)
    {
      if(setting.rank > _maxRank){
        _maxRank = setting.rank;
        _topRankRange = setting;
      }
      if(setting.rank < _lowestRankRange.rank) _lowestRankRange = setting;
    }
  }

  int getSqLoadRange(int rank)
  {
    RangeSetting setting = getRangeSetting(rank);
    return setting.sqLoadRange;
  }

  int getSqUnloadRange(int rank)
  {
    RangeSetting setting = getRangeSetting(rank);
    return setting.sqUnloadRange;
  }

  /// Gets the rangesetting with highest rank below argument rank.
  private RangeSetting getRangeSetting(int rank)
  {
    RangeSetting rangeSetting = _lowestRankRange;
    foreach(setting; _settings)
    {
      if(setting.rank > rangeSetting.rank && setting.rank < rank) rangeSetting = setting;
    }
    return rangeSetting;
  }
}