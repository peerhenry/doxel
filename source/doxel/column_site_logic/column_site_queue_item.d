import gfm.math:vec2i;

enum ColumnSiteState
{
  UNEVALUATED,
  HAS_HEIGHT,
  HAS_CHUNKS,
  ON_STAGE
}

class ColumnSiteQueueItem
{
  ColumnSiteState state;
  float camDistanceSq;
  vec2i site;
}