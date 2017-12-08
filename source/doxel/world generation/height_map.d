import gfm.math:vec2i;

// height map settings

const static int mapCellWidth = 8;
const static int mapCellLength = 8;
const static int heightCellCount = mapCellLength*mapCellWidth;
const static vec2i cellCenter = vec2i(mapCellWidth/2, mapCellLength/2);

// calculator

static int cellSiteToIndex(vec2i cellSite) pure
{
  return cellSite.x + mapCellWidth * cellSite.y;
}

// interfaces + base class

interface IMapCell
{
  @property int rank();
  @property vec2i site();
  @property int siteIndex();
}

interface IMapCellContainer : IMapCell
{
  @property IMapCell[heightCellCount] cells();
  IMapCell getMapCell(vec2i cellSite);
}

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
    _siteIndex = cellSiteToIndex(site);
  }

  this(IMapCellContainer container, vec2i site)
  {
    _rank = container.rank - 1;
    _site = site;
    _siteIndex = cellSiteToIndex(site);
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

// container

class MapCellContainer : BaseMapCell, IMapCellContainer
{
  private IMapCell[heightCellCount] _cells;
  @property IMapCell[heightCellCount] cells(){ return _cells; }

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

  void addMapCell(IMapCell mapCell)
  {
    assert(mapCell.rank == _rank-1);
    _cells[mapCell.siteIndex] = mapCell;
  }

  IMapCell getMapCell(vec2i cellSite)
  {
    return _cells[cellSiteToIndex(cellSite)];
  }
}

// height cell

class HeightCell : BaseMapCell
{
  private int[heightCellCount] _heights;
  @property int[heightCellCount] heights(){ return _heights; }

  this(IMapCellContainer container, int[heightCellCount] heights, vec2i site)
  {
    assert(container.rank == 2);
    super(container, site);
    _heights = heights;
  }

  int getHeight(vec2i cellSite)
  {
    int index = cellSiteToIndex(cellSite);
    return getHeight(index);
  }

  int getHeight(int cellIndex)
  {
    return _heights[cellIndex];
  }
}

// height map

class HeightMap
{
  private IMapCellContainer _topCell;
  @property IMapCellContainer topCell() {return _topCell; }

  this()
  {
    _topCell = new MapCellContainer(2);
  }

  int getHeight(vec2i[int] mapSite)
  {
    int maxHeight = getMaxHeight(mapSite);
    HeightCell heightCell = getHeightCell(mapSite, maxHeight);
    return heightCell.getHeight(mapSite[0]);
  }

  private int getMaxHeight(vec2i[int] mapSite)
  {
    int maxRank = 1;
    int topCellRank = _topCell.rank;
    vec2i* nextCellSite = (maxRank in mapSite);
    while(nextCellSite !is null && maxRank <= topCellRank)
    {
      maxRank++;
      nextCellSite = (maxRank in mapSite);
    }
    // Either nextRank surpassed topcellrank or it doesn't exist in mapSite. Either way, subtract 1.
    return maxRank-1;
  }

  private HeightCell getHeightCell(vec2i[int] mapSite, int maxRank)
  {
    IMapCellContainer nextContainer = _topCell;
    while(nextContainer.rank > maxRank + 1)
    {
      nextContainer = cast(IMapCellContainer)(nextContainer.getMapCell(cellCenter));
    }
    while(nextContainer.rank > 0)
    {
      int nextRank = nextContainer.rank - 1;
      nextContainer = cast(IMapCellContainer)(nextContainer.getMapCell(mapSite[nextRank]));
    }
    return cast(HeightCell)nextContainer;
  }

  unittest
  {
    import testrunner;
    runtest("getMaxHeight with higher max rank than topcell gets topcell rank", delegate bool(){
      // arrange
      auto map = new HeightMap();
      vec2i[int] mapSite = [0: vec2i(0,0), 1: vec2i(0,0), 2: vec2i(0,0), 3: vec2i(0,0)];
      // act
      auto result = map.getMaxHeight(mapSite);
      // assert
      assertEqual(map._topCell.rank, result);
      return true;
    });
  }
}