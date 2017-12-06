import gfm.math;
import iregion;

interface IRegionContainer : IRegion
{
  void addRegion(IRegion region);
  IRegion getRegion(vec3i site);
  IRegion getCreateRegion(vec3i site);
  IRegion[] getRegions();
}