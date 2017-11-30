import gfm.math;
import iregion, chunk, region, sides;

class World
{
  Region topRegion;

  this(Region region)
  {
    this.topRegion = region;
  }

  pure bool isOutOfBounds(vec3i site)
  {
    return site.x < 0 || site.y < 0 || site.z < 0
        || site.x > 7 || site.y > 7 || site.z > 3;
  }

  pure vec3i siteModulo(vec3i site)
  {
    vec3i newSite = site;
    if(newSite.x >= 8) newSite.x = newSite.x % 8;
    else while(newSite.x < 0) newSite.x += 8;
    if(newSite.y >= 8) newSite.y = newSite.y % 8;
    else while(newSite.y < 0) newSite.y += 8;
    if(newSite.z >= 4) newSite.z = newSite.z % 4;
    else while(newSite.z < 0) newSite.z += 4;
    return newSite;
  }

  Chunk getAdjacentChunk(Chunk chunk, SideDetails side)
  {
    return cast(Chunk)getCreateAdjacentRegion(chunk, side);
  }

  IRegion getCreateAdjacentRegion(IRegion region, SideDetails side)
  {
    vec3i adjSite = region.getSite() + side.normali;
    bool outOfBounds = isOutOfBounds(adjSite);
    if(outOfBounds)
    {
      Region adjacentContainer = cast(Region)getCreateAdjacentRegion(region.getContainer(), side);
      vec3i inBoundsSite = siteModulo(adjSite);
      return adjacentContainer.getCreateRegion(inBoundsSite);
    }
    else
    {
      Region container;
      if(region is this.topRegion)
      {
        container = new Region(region);
        this.topRegion = container;
      }
      else
      {
        container = cast(Region)region.getContainer();
      }
      return container.getCreateRegion(adjSite);
    }
  }
}