import gfm.math;

interface IRegion
{
  int getRank();
  IRegion getContainer();
  vec3i getSite();
  int getSiteIndex();
}