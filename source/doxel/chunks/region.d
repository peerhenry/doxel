import gfm.math;

import chunk, iregion, baseregion;

class Region: BaseRegion
{
  IRegion[256] regions;

  this(Region container, vec3i site)
  {
    assert(container.rank > 1);
    super(container.rank + 1, site);
    this.container = container;
  }

  this(IRegion subRegion)
  {
    super(subRegion.getRank()+1, vec3i(4,4,2));
    regions[subRegion.getSiteIndex()] = subRegion;
  }

  /// Beware, the coordinates must be in bounds: 0<=i<8, 0<=j<8, 0<=k<4
  IRegion getRegion(int i, int j, int k)
  {
    int index = i + 8*j + 64*k;
    return regions[index];
  }

  /// Creates a chunk if there is none at given coordinate
  IRegion getCreateRegion(vec3i site)
  {
    int index = site.x + 8*site.y + 64*site.z;
    IRegion reg = regions[index];
    if(reg is null)
    {
      if(rank == 2)
      {
        reg = new Chunk(this, site);
      }
      else reg = new Region(this, site);
      regions[index] = reg;
    }
    return reg;
  }
}