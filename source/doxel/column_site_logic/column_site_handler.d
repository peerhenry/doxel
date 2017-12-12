import std.math:floor;
import gfm.math:vec2i;
import i_column_site_provider, camera, limiter, column_site_queue_item, i_column_site_action, worldsettings;

class ColumnSiteIterator
{
  private Limiter _limiter;
  private int _trackIndex;
  private IColumnSiteAction _colSiteAction;
  private ColumnSiteState _requiredState;

  this(Limiter limiter, IColumnSiteAction colSiteAction, ColumnSiteState requiredState)
  {
    _limiter = limiter;
    _colSiteAction = colSiteAction;
    _requiredState = requiredState;
  }

  void update(ColumnSiteQueueItem[] queue)
  {
    if(_trackIndex < queue.length)
    {
      while(!_limiter.limitReached())
      {
        ColumnSiteQueueItem nextItem = queue[_trackIndex];
        if(nextItem.state == _requiredState)
        {
          _colSiteAction.perform( nextItem );
          _limiter.increment();
        }
        _trackIndex++;
      }
      _limiter.reset();
    }
  }

  void resetTracker()
  {
    _trackIndex = 0;
  }
}

import std.array;

class ColumnSiteHandler
{
  private{
    Camera _cam;
    ColumnSiteMap _colSiteMap;
    IColumnSiteProvider _columnSiteProvider;
    vec2i _lastCamColSite;
    vec2i[] _colSites;
    ColumnSiteQueueItem[] _queue;
    ColumnSiteIterator[] _iterators;
  }

  this(Camera cam, IColumnSiteProvider columnSiteProvider, ColumnSiteIterator[] iterators)
  {
    _cam = cam;
    _columnSiteProvider = columnSiteProvider;
    _lastCamColSite = getCamColSite(cam) + vec2i(999,999);
    _iterators = iterators;
  }

  void update()
  {
    bool shouldRenewQueue = updateColSites();
    if(shouldRenewQueue) renewQueue(_colSites);
    updateColSiteIterators();
  }

  private bool updateColSites()
  {
    vec2i camColSite = vec2i(
      cast(int)floor(_cam.position.x/regionWidth),
      cast(int)floor(_cam.position.y/regionHeight)
    );

    if(camColSite != _lastCamColSite && camColSite.squaredDistanceTo(_lastCamColSite) > 2*regionWidth*regionWidth)
    {
      _colSites = _columnSiteProvider.getColumnSites(camColSite);
      _lastCamColSite = camColSite;
      foreach(iter; _iterators)
      {
        iter.resetTracker();
      }
      return true;
    }
    return false;
  }

  private void renewQueue(vec2i[] colSites)
  {
    auto qAppender = appender!(ColumnSiteQueueItem[])();
    qAppender.reserve(colSites.length);
    foreach(vec2i colSite; colSites)
    {
      ColumnSiteQueueItem qItem = _colSiteMap.get(colSite);
      if(qItem is null)
      {
        // create new qItem
        qItem = new ColumnSiteQueueItem();
        _colSiteMap.insert(colSite, qItem);
      }
      qItem.camDistanceSq = getHCamDSq(_cam, colSite);
      qAppender.put(qItem);
    }
    _queue = qAppender.data();
  }

  private void updateColSiteIterators()
  {
    foreach(iter; _iterators)
    {
      iter.update(_queue);
    }
  }

  private vec2i getCamColSite(Camera cam)
  {
    return vec2i(
      cast(int)floor(cam.position.x/regionWidth),
      cast(int)floor(cam.position.y/regionHeight)
    );
  }

  /// Get horizontal squared distance to camera
  private float getHCamDSq(Camera cam, vec2i site)
  {
    float dx = site.x*regionWidth - cam.position.x;
    float dy = site.y*regionLength - cam.position.y;
    return dx*dx+dy*dy;
  }
}

class ColumnSiteMap
{
  private ColumnSiteQueueItem[int][int] _colSiteMap;

  ColumnSiteQueueItem get(vec2i site)
  {
    ColumnSiteQueueItem[int]* qrow = (site.x in _colSiteMap);
    if(qrow is null) return null;
    ColumnSiteQueueItem* qitem = (site.y in *qrow);
    return *qitem;
  }

  void insert(vec2i site, ColumnSiteQueueItem qitem)
  {
    _colSiteMap[site.x][site.y] = qitem;
  }

  void remove(vec2i site)
  {
    _colSiteMap[site.x].remove(site.y);
  }
}

unittest{
  import testrunner;

  runsuite("ColumnSiteMap", delegate void(){
    runtest("insert contains", delegate void(){
      // arrange
      ColumnSiteMap map = new ColumnSiteMap();
      auto qi = new ColumnSiteQueueItem();
      qi.camDistanceSq = 10.0;
      vec2i site = vec2i(4,5);
      // act
      map.insert(site, qi);
      auto result = map.get(site);
      // assert
      assertEqual(qi.camDistanceSq, result.camDistanceSq);
    });
  });
}