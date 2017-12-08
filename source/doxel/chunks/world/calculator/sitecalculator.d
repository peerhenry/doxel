import std.math;
import gfm.math;
import coordcalculator, worldsettings;
public alias calculator = SiteCalculator;

immutable static int yOffset = regionWidth;
immutable static int zOffset = regionWidth*regionLength;

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

  static int siteToIndex(int i, int j, int k)
  {
    return i + yOffset*j + zOffset*k;
  }

  static int siteToIndex(vec3i site)
  {
    return site.x + yOffset*site.y + zOffset*site.z;
  }

  pure vec3i siteIndexToSite(int index)
  {
    int i = index%yOffset;
    int k = index/zOffset;
    int j = (index-k*zOffset)/yOffset;
    return vec3i(i,j,k);
  }

  pure bool withinBounds(vec3i site)
  {
    return !isOutOfBounds(site);
  }

  /// Checks if a site is outside region bounds
  pure bool isOutOfBounds(vec3i site)
  {
    return site.x < 0 || site.y < 0 || site.z < 0
        || site.x > siteMax.x || site.y > siteMax.y || site.z > siteMax.z;
  }

  import std.array, std.conv;

  // Speed-up CTFE conversions
  private string ctIntToString(int n) pure nothrow
  {
    static immutable string[16] table = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    if (n < 10)
        return table[n];
    else
        return to!string(n);
  }

  private string generateLoopCode(string formatString, int N)() pure nothrow
  {
    string result;
    for (int i = 0; i < N; ++i)
    {
      string index = ctIntToString(i);
      // replace all @ by indices
      result ~= formatString.replace("@", index);
    }
    return result;
  }

  /// Calculates the effective site it will have inside a region
  pure vec3i siteModulo(vec3i site)
  {
    vec3i newSite = site;
    mixin(generateLoopCode!("newSite[@] = newSite[@] % regionSize[@]; if(newSite[@] < 0) newSite[@] += regionSize[@];", 3));
    return newSite;
  }

  /// calculates site modulo of a site dimension with given region size along that dimension.
  pure int siteCompModulo(int siteComp, int regCompSize)
  {
    int modSitec = siteComp % regCompSize;
    if(modSitec < 0) modSitec += regCompSize;
    return modSitec;
  }

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
    if(site.x > siteMax.x || site.y > siteMax.y || site.z > siteMax.z || site.x < 0 || site.y < 0 || site.z < 0)
    {
      vec3i nextSite = regionCenter + vec3i(
        cast(int)floor((cast(float)site.x)/regionWidth),
        cast(int)floor((cast(float)site.y)/regionLength),
        cast(int)floor((cast(float)site.z)/regionHeight)
      );
      rec(worldSite, rank+1, nextSite);
    }
  }

}