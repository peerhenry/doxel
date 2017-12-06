import std.math;
import gfm.math;
import coordcalculator;
public alias calculator = SiteCalculator;
class SiteCalculator : CoordCalculator
{
  static:

  pure int getMaxRank(vec3i[int] worldSite)
  {
    int maxRank = 1;
    while(true)
    {
      if( ((maxRank + 1) in worldSite) is null ) break;
      else maxRank++;
    }
    return maxRank;
  }

  pure vec3i siteIndexToSite(int index)
  {
    int i = index%8;
    int k = index/64;
    int j = (index-k*64)/8;
    return vec3i(i,j,k);
  }

  /// Checks if a site is outside region bounds
  pure bool isOutOfBounds(vec3i site)
  {
    return site.x < 0 || site.y < 0 || site.z < 0
        || site.x > 7 || site.y > 7 || site.z > 3;
  }

  /// Calculates the effective site it will have inside a region
  pure vec3i siteModulo(vec3i site)
  {
    vec3i newSite = site;
    newSite.x = newSite.x % 8;
    if(newSite.x < 0) newSite.x += 8;
    newSite.y = newSite.y % 8;
    if(newSite.y < 0) newSite.y += 8;
    newSite.z = newSite.z % 4;
    if(newSite.z < 0) newSite.z += 4;
    return newSite;
  }

  // I don't want to allow any absolute calculations, only relative...
  /// Convert world site to global chunk site
  /*pure vec3i toGlobalSite(vec3i[int] worldSite)
  {
    int rank = 1;
    vec3i* nextSite = rank in worldSite;
    vec3i globalSite;
    while(nextSite !is null)
    {
      rank++;
      globalSite.x += ((*nextSite).x - 4)*pow(8, rank);
      globalSite.y += ((*nextSite).y - 4)*pow(8, rank);
      globalSite.z += ((*nextSite).z - 2)*pow(4, rank);
      nextSite = rank in worldSite;
    }
    return globalSite;
  }*/

  /// Converts a global chunk site to a world site
  pure vec3i[int] toWorldSite(vec3i site)
  {
    vec3i[int] worldSite;
    rec(worldSite, 1, site);
    return worldSite;
  }

  pure private void rec(ref vec3i[int] worldSite, int rank, vec3i site)
  {
    worldSite[rank] = siteModulo(site);
    if(site.x > 7 || site.y > 7 || site.z > 3 || site.x < 0 || site.y < 0 || site.z < 0)
    {
      vec3i nextSite = vec3i(
        4 + cast(int)floor((cast(float)site.x)/8),
        4 + cast(int)floor((cast(float)site.y)/8),
        2 + cast(int)floor((cast(float)site.z)/4)
      );
      rec(worldSite, rank+1, nextSite);
    }
  }

}