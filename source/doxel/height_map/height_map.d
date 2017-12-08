import std.typecons;
import gfm.math:vec2i;
import doxel_height_map;

class HeightMap
{
  private IMapCellContainer _topCell;
  @property IMapCellContainer topCell() { return _topCell; }

  this()
  {
    _topCell = new MapCellContainer(2);
  }

  /// Creates a container for the top cell and returns the new top cell.
  IMapCellContainer expand()
  {
    _topCell = MapCellContainer.createContainerFor(_topCell);
    return _topCell;
  }

  HeightCell createHeightCell(vec2i[int] mapSite, int[mapCellCount] heights)
  {
    auto hcContainer = getCreateHeightCellContainer(mapSite);
    return new HeightCell(hcContainer, heights, mapSite[1]);
  }

  Nullable!int getHeight(vec2i[int] mapSite)
  {
    HeightCell heightCell = getHeightCell(mapSite);
    if(heightCell is null) return Nullable!int();
    else return Nullable!int(heightCell.getHeight(mapSite[1]));
  }

  HeightCell getHeightCell(vec2i[int] mapSite)
  {
    int maxRank = getMaxRank(mapSite);
    return cast(HeightCell)getMapCell(mapSite, maxRank, 1);
  }

  IMapCellContainer getHeightCellContainer(vec2i[int] mapSite)
  {
    int maxRank = getMaxRank(mapSite);
    return cast(IMapCellContainer)getMapCell(mapSite, maxRank, 2);
  }

  IMapCellContainer getCreateHeightCellContainer(vec2i[int] mapSite)
  {
    int maxRank = getMaxRank(mapSite);
    return cast(IMapCellContainer)getCreateMapCell(mapSite, maxRank, 2);
  }

  /// Gets the highest key in mapsite
  private int getMaxRank(vec2i[int] mapSite)
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

  /// if the targetrank is greater or equal to the topcell, it returns the topcell
  private IMapCell getMapCell(vec2i[int] mapSite, int maxRank, int targetRank)
  {
    return retrieveMapCell(mapSite, maxRank, targetRank, _topCell, false);
  }

  private IMapCell getCreateMapCell(vec2i[int] mapSite, int maxRank, int targetRank)
  {
    assert(targetRank > 1);
    while(maxRank >= _topCell.rank) expand();
    return retrieveMapCell(mapSite, maxRank, targetRank, _topCell, true);
  }

  static private IMapCell retrieveMapCell(vec2i[int] mapSite, int maxRank, int targetRank, IMapCell startCell, bool withCreate)
  {
    IMapCell nextCell = startCell;
    vec2i nextSite = cellCenter;
    while(nextCell !is null && nextCell.rank > targetRank)
    {
      if(nextCell.rank > maxRank+1) nextSite = cellCenter; // as soon as cell reaches maxrank+1, start using mapSite
      else nextSite = mapSite[nextCell.rank-1]; // what is the site one rank below nextCell
      IMapCellContainer nextContainer = cast(IMapCellContainer)nextCell;
      nextCell = nextContainer.getMapCell(nextSite);
      if(nextCell is null) nextCell = withCreate ? new MapCellContainer(nextContainer, nextSite) : null;
    }
    return nextCell;
  }

  unittest
  {
    import testrunner;

    beginSuite("height_map");

    runtest("getMaxRank with higher max rank than topcell gets topcell rank", delegate void(){
      // arrange
      auto map = new HeightMap();
      vec2i[int] mapSite = [0: vec2i(0,0), 1: vec2i(0,0), 2: vec2i(0,0), 3: vec2i(0,0)];
      // act
      auto result = map.getMaxRank(mapSite);
      // assert
      assertEqual(map._topCell.rank, result);
    });

    runtest("getMapCell 1", delegate void(){
      // arrange
      auto map = new HeightMap();
      map.expand();
      map.expand();
      map.expand();
      // act
      IMapCell result = map.getMapCell([0:cellCenter, 1:cellCenter, 2:cellCenter], 1, 2);
      // assert
      assert(result !is null);
      assertEqual(2, result.rank);
      assertEqual(cellCenter, result.site);
    });

    runtest("getCreateMapCell 1", delegate void(){
      // arrange
      auto map = new HeightMap();
      map.expand();
      map.expand();
      // act
      IMapCell result = map.getCreateMapCell([2: vec2i(1,1), 3: vec2i(0,0)], 3, 2);
      // assert
      assert(result !is null);
      assertEqual(2, result.rank);
      assertEqual(vec2i(1,1), result.site);
    });

    endSuite();
  }
}