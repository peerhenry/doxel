import gfm.math:vec2i;
import map_site_calculator, height_map_settings, i_map_cell, base_map_cell, i_map_cell_container;

// container

class MapCellContainer : BaseMapCell, IMapCellContainer
{
  private IMapCell[mapCellCount] _cells;
  @property IMapCell[mapCellCount] cells(){ return _cells; }

  this(IMapCellContainer container, vec2i site)
  {
    super(container, site);
  }

  // constructor for world
  this(int rank)
  {
    assert(rank > 1);
    super(rank, cellCenter);
  }

  static MapCellContainer createContainerFor(IMapCell mapCell)
  {
    auto newMcc = new MapCellContainer(mapCell.rank+1);
    newMcc.addMapCell(mapCell);
    return newMcc;
  }

  void addMapCell(IMapCell mapCell)
  {
    assert(mapCell.rank == _rank-1);
    _cells[mapCell.siteIndex] = mapCell;
  }

  IMapCell getMapCell(vec2i cellSite)
  {
    return _cells[MapSiteCalculator.cellSiteToIndex(cellSite)];
  }
}