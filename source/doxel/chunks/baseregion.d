import gfm.math;

import chunk, iregion;

abstract class BaseRegion: IRegion
{
  IRegion container;
  immutable int rank;
  immutable vec3i site;

  this(int rank, vec3i site)
  {
    this.rank = rank;
    this.site = site;
  }

  int getRank()
  {
    return rank;
  }

  IRegion getContainer()
  {
    return container;
  }

  vec3i getSite()
  {
    return site;
  }

  int getSiteIndex()
  {
    return site.x + 8*site.y + 64*site.z;
  }
}