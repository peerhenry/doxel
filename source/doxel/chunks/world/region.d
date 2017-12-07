import gfm.math;

import chunk, iregion, baseregion, iregioncontainer;

class Region: BaseRegion, IRegionContainer
{
  IRegion[256] regions;

  this(IRegionContainer container, vec3i site)
  {
    assert(container.getRank() > 2);
    super(container.getRank() - 1, site);
    this.container = container;
  }

  this(IRegion subRegion)
  {
    assert(subRegion.getRank() >= 1);
    super(subRegion.getRank()+1, vec3i(4,4,2));
    regions[subRegion.getSiteIndex()] = subRegion;
    subRegion.setContainer(this);
  }

  this(int rank)
  {
    assert(rank > 1);
    super(rank, vec3i(4,4,2));
  }

  IRegion getRegion(vec3i site)
  {
    int index = site.x + 8*site.y + 64*site.z;
    return regions[index];
  }

  IRegion[] getRegions()
  {
    return regions;
  }

  void addRegion(IRegion region)
  {
    regions[region.getSiteIndex()] = region;
  }

  /// Creates a region if there is none at given site
  IRegion getCreateRegion(vec3i site)
  {
    int index = site.x + 8*site.y + 64*site.z;
    IRegion reg = regions[index];
    if(reg is null)
    {
      assert(rank > 2); // make syre the region will not create a chunk; that's world's job
      reg = new Region(this, site);
      regions[index] = reg;
    }
    return reg;
  }
}