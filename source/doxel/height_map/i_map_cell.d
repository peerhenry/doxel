import gfm.math:vec2i;
import map_site_calculator, height_map_settings;

interface IMapCell
{
  @property int rank();
  @property vec2i site();
  @property int siteIndex();
}