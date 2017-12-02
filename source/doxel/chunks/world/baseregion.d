import gfm.math;

import chunk, iregion, iregioncontainer;

abstract class BaseRegion: IRegion
{
  IRegionContainer container;
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

  IRegionContainer getContainer()
  {
    return container;
  }

  void setContainer(IRegionContainer container)
  {
    assert(container !is null);
    assert(container.getRank() == this.rank+1);
    this.container = container;
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