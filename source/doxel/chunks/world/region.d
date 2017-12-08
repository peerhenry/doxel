import gfm.math;
import chunk, iregion, baseregion, iregioncontainer, worldsettings;

class Region: BaseRegion, IRegionContainer
{
  IRegion[regionCount] regions;

  this(IRegionContainer container, vec3i site)
  {
    assert(container.getRank() > 2);
    super(container.getRank() - 1, site);
    this.container = container;
  }

  // dangerous constructor: client doesn't know if the parameter will be a subregion or a container
  private this(IRegion subRegion)
  {
    assert(subRegion.getRank() >= 1);
    super(subRegion.getRank()+1, regionCenter);
    regions[subRegion.getSiteIndex()] = subRegion;
    subRegion.setContainer(this);
  }

  this(int rank)
  {
    assert(rank > 1);
    super(rank, regionCenter);
  }

  static Region createContainerFor(IRegion subRegion)
  {
    return new Region(subRegion);
  }

  IRegion getRegion(vec3i site)
  {
    int index = site.x + regionSize.x*site.y + regionSize.x*regionSize.y*site.z;
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
    int index = site.x + regionSize.x*site.y + regionSize.x*regionSize.y*site.z;
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