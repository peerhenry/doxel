import gfm.math:vec2i;
import doxel_height_map;

interface IMapCellContainer : IMapCell
{
  @property IMapCell[mapCellCount] cells();
  IMapCell getMapCell(vec2i cellSite);
  void addMapCell(IMapCell mapCell);
}