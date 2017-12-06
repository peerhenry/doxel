import gfm.math;
import iregioncontainer;

interface IRegion
{
  int getRank();
  IRegionContainer getContainer();
  void setContainer(IRegionContainer);
  vec3i getSite();
  int getSiteIndex();
}