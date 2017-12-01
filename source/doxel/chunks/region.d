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
    super(subRegion.getRank()+1, vec3i(4,4,2));
    regions[subRegion.getSiteIndex()] = subRegion;
    subRegion.setContainer(this);
  }

  this(int rank)
  {
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