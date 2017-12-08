import gfm.math:vec2i;
import map_site_calculator, height_map_settings, i_map_cell, i_map_cell_container;

abstract class BaseMapCell: IMapCell
{
  protected IMapCellContainer container;
  immutable int _rank;
  @property int rank(){return _rank;}
  immutable vec2i _site;
  @property vec2i site(){return _site;};
  immutable int _siteIndex;
  @property int siteIndex(){return _siteIndex;}

  this(int rank, vec2i site)
  {
    _rank = rank;
    _site = site;
    _siteIndex = MapSiteCalculator.cellSiteToIndex(site);
  }

  this(IMapCellContainer container, vec2i site)
  {
    _rank = container.rank - 1;
    _site = site;
    _siteIndex = MapSiteCalculator.cellSiteToIndex(site);
    container.addMapCell(this);
    this.container = container;
  }

  IMapCellContainer getContainer()
  {
    return container;
  }

  void setContainer(IMapCellContainer container)
  {
    assert(container !is null);
    assert(container.rank == _rank+1);
    this.container = container;
  }
}