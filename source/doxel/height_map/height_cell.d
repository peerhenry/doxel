import gfm.math:vec2i;
import map_site_calculator, height_map_settings, base_map_cell, i_map_cell_container;

class HeightCell : BaseMapCell
{
  private int[mapCellCount] _heights;
  @property int[mapCellCount] heights(){ return _heights; }

  this(IMapCellContainer container, int[mapCellCount] heights, vec2i site)
  {
    assert(container.rank == 2);
    super(container, site);
    _heights = heights;
  }

  int getHeight(vec2i cellSite)
  {
    int index = cellSite.x + mapCellWidth * cellSite.y;
    return getHeight(index);
  }

  int getHeight(int i, int j)
  {
    int index = i + mapCellWidth * j;
    return getHeight(index);
  }

  int getHeight(int cellIndex)
  {
    return _heights[cellIndex];
  }
}