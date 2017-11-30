import std.math;
import gfm.math;
import iregion, iregioncontainer, chunk, region, sides, blocks;

class World
{
  IRegionContainer topRegion;

  this()
  {
    this.topRegion = new Region(2);
  }

  private void rec(ref vec3i[int] worldSite, int rank, vec3i site)
  {
    worldSite[rank] = vec3i(
      site.x < 0 ? 8-(abs(site.x)%8) : site.x%8, 
      site.y < 0 ? 8-(abs(site.y)%8) : site.y%8, 
      site.z < 0 ? 4-(abs(site.z)%4) : site.z%4
    );
    if(site.x > 7 || site.y > 7 || site.z > 3 || site.x < 0 || site.y < 0 || site.z < 0)
    {
      int nextI = site.x < 0 ? 3 + site.x/8 : 4 + site.x/8;
      int nextJ = site.y < 0 ? 3 + site.y/8 : 4 + site.y/8;
      int nextK = site.z < 0 ? 1 + site.z/4 : 2 + site.z/4;
      rec(worldSite, rank+1, vec3i(nextI, nextJ, nextK));
    }
  }

  import std.stdio, std.format;
  vec3i[int] getWorldSite(vec3i site)
  {
    vec3i[int] worldSite;
    rec(worldSite, 1, site);
    return worldSite;
  }

  void addChunk(vec3i site, Block block)
  {
    // dictionary with int keys and vec3i values.
    vec3i[int] worldSite = getWorldSite(site);
    int maxRank = 1;
    while(true)
    {
      vec3i lesite = worldSite[maxRank];
      string msg = format!"rank: %s site: (%s, %s, %s)"(maxRank, lesite.x, lesite.y, lesite.z);
      writeln( msg );

      if( ((maxRank + 1) in worldSite) is null ) break;
      maxRank++;
    }

    while(maxRank >= this.topRegion.getRank()) // the topregion must be 1 rank above max rank in worldsite.
    {
      this.topRegion = new Region(this.topRegion);
    }

    IRegionContainer container = this.topRegion;
    // Get or create regions down the ranks
    while(container.getRank() > 2)
    {
      if(container.getRank() > maxRank+1)
      {
        container = cast(IRegionContainer) container.getCreateRegion(vec3i(4,4,2));
      }
      else
      {
        vec3i regSite = worldSite[container.getRank() - 1];
        writeln(format!"now using worldSite to access a region of rank %s regSite: %s"((container.getRank() - 1), regSite.toString()));
        container = cast(IRegionContainer) container.getCreateRegion(regSite);
      }
    }

    if(container.getRegion(worldSite[1]) is null)
    {
      writeln(format!"now creating chunk in world with container site %s"(container.getSite().toString()));
      new Chunk(container, worldSite[1], block);
    }
    else
    {
      string msg1 = format!"NOT creating chunk in region: %s site: %s"(container.getRank(), container.getSite().toString());
      string msg2 = format!"Chunk would have had site: %s"(worldSite[1].toString());
      writeln( msg1 );
      writeln( msg2 );
    }
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
    return cast(Chunk)getAdjacentRegion(chunk, side);
  }

  IRegion getAdjacentRegion(IRegion region, SideDetails side)
  {
    vec3i adjSite = region.getSite() + side.normali;
    bool outOfBounds = isOutOfBounds(adjSite);
    if(outOfBounds)
    {
      Region adjacentContainer = cast(Region)getAdjacentRegion(region.getContainer(), side);
      if(adjacentContainer is null) return null;
      vec3i inBoundsSite = siteModulo(adjSite);
      return adjacentContainer.getRegion(inBoundsSite);
    }
    else
    {
      if(region is this.topRegion)
      {
        return null;
      }
      else
      {
        IRegionContainer container = region.getContainer();
        return container.getRegion(adjSite);
      }
    }
  }

  /// will create chunk and necessary regions if not present
  Chunk getCreateAdjacentChunk(Chunk chunk, SideDetails side)
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
      IRegionContainer container;
      if(region is this.topRegion)
      {
        container = new Region(region);
        this.topRegion = container;
      }
      else
      {
        container = region.getContainer();
      }
      return container.getCreateRegion(adjSite);
    }
  }
}