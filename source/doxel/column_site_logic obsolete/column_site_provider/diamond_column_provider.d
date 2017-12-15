import std.array;
import gfm.math:vec2i;
import i_column_site_provider, limiter;

/// Provides column sites, spiraling outward from the center in a diamond shape
class DiamondColumnProvider: IColumnSiteProvider
{
  private Limiter _limiter;
  private static const vec2i[3] dirs = [vec2i(-1,-1), vec2i(1,-1), vec2i(1,1)];

  this(Limiter limiter)
  {
    _limiter = limiter;
  }

  vec2i[] getColumnSites(vec2i center)
  {
    auto colSiteAppender = appender!(vec2i[])();
    colSiteAppender.reserve(_limiter.limit);
    appendSite(colSiteAppender, center, vec2i(0,0));
    vec2i next_ij = center;
    int shell = 0;    
    while( !_limiter.limitReached() )
    {
      // go up
      next_ij = appendSite(colSiteAppender, next_ij, vec2i(0,1));
      // go upleft
      foreach(n; 0..shell)
      {
        next_ij = appendSite(colSiteAppender, next_ij, vec2i(-1,1));
      }
      shell++; // expand shell;
      foreach(dir; dirs) // go downleft, downright and upright
      {
        foreach(n; 0..shell)
        {
          next_ij = appendSite(colSiteAppender, next_ij, dir);
        }
      }
    }
    return colSiteAppender.data;
  }

  private vec2i appendSite(Appender!(vec2i[]) colSites, vec2i site, vec2i delta)
  {
    vec2i next_site = site + delta;
    colSites.put(next_site);
    _limiter.increment;
    return next_site;
  }
}