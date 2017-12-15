import gfm.math:vec2i;
import chunk;

enum ColumnSiteState
{
  UNEVALUATED,
  HAS_HEIGHT,
  HAS_CHUNKS,
  ON_STAGE,
  IN_GROUP
}

class ColumnSiteQueueItem
{
  ColumnSiteState state;
  float camDistanceSq;
  vec2i site;
  Chunk[] chunks;
  QueueItemGroup group;
}

class QueueItemGroup
{
  private ColumnSiteQueueItem[] _items;
  void add(ColumnSiteQueueItem item)
  {
    _items ~= item;
    item.group = this;
  }
  ColumnSiteQueueItem[] items(){ return _items; }
}