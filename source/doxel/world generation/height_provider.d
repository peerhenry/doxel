import std.math:floor; //import std.typecons:Nullable;
import gfm.math:vec2i;
import doxel_height_map, height_generator;

interface IHeightProvider 
{
  int getHeight(int i, int j);
  void setOffset(int h);
}

class FlatHeightProvider
{
  int height;
  this(){}
  this(int height){this.height = height;}
  int getHeight(int i, int j){return height;}
  void setOffset(int h){}
}

class HeightProvider: IHeightProvider
{
  private IHeightGenerator generator;
  private HeightMap heightMap;
  private int offset;

  this(IHeightGenerator generator, HeightMap heightMap)
  {
    this.generator = generator;
    this.heightMap = heightMap;
  }

  this(IHeightGenerator generator, HeightMap heightMap, int offset)
  {
    this.generator = generator;
    this.heightMap = heightMap;
    this.offset = offset;
  }

  void setOffset(int h){offset = h;}

  int getHeight(int i, int j)
  {
    return getGenerate(i, j) + offset;
    //return generator.generateHeight(i, j);
  }

  /// gets the height from heightmap, or generates it if it hasn't been yet.
  private int getGenerate(int i, int j)
  {
    vec2i[int] mapSite = MapSiteCalculator.toMapSite(i, j);
    auto container = heightMap.getCreateHeightCellContainer(mapSite);
    HeightCell cell = cast(HeightCell)container.getMapCell(mapSite[1]);
    
    if(cell is null)
    {
      int[mapCellCount] heights;
      auto offsetI = (cast(int)floor((cast(float)i)/mapCellWidth))*mapCellWidth;
      auto offsetJ = (cast(int)floor((cast(float)j)/mapCellLength))*mapCellLength;
      foreach(ii;0..mapCellWidth)
      {
        foreach(jj;0..mapCellLength)
        {
          heights[ii + mapCellWidth*jj] = generator.generateHeight(offsetI + ii, offsetJ + jj);
        }
      }
      cell = new HeightCell(container, heights, mapSite[1]);
    }
    return cell.getHeight(mapSite[0]);
  }

  unittest{
    import testrunner;

    class MockHeightProvider: IHeightGenerator
    {
      int generateHeight(int i, int j){                 //  16 | 18
        int h = i<0 ? (j<0 ? 15: 16) : (j<0 ? 17: 18);  // ---------
        return h;                                       //  15 | 17
      }
    }

    beginSuite("height_provider");

    runtest("getGenerate(0,0)", delegate void(){
      // arrange
      auto map = new HeightMap();
      auto provider = new HeightProvider(new MockHeightProvider(), map);
      // act
      provider.getGenerate(0,0);
      // assert
      auto result = map.getHeightCell([1: cellCenter, 2: cellCenter]);
      assert(result !is null);
      assertEqual(18, result.getHeight(1,1));
    });

    runtest("getGenerate(-1,-1)", delegate void(){
      // arrange
      auto map = new HeightMap();
      auto provider = new HeightProvider(new MockHeightProvider(), map);
      // act
      provider.getGenerate(-1,-1);
      // assert
      auto result = map.getHeightCell([1: cellCenter-vec2i(1,1), 2: cellCenter]);
      assert(result !is null);
      assertEqual(15, result.getHeight(1,1));
    });

    runtest("getGenerate(-1,0)", delegate void(){
      // arrange
      auto map = new HeightMap();
      auto provider = new HeightProvider(new MockHeightProvider(), map);
      // act
      provider.getGenerate(-1,1);
      // assert
      auto result = map.getHeightCell([1: cellCenter+vec2i(-1,0), 2: cellCenter]);
      assert(result !is null);
      assertEqual(16, result.getHeight(1,1));
    });

    endSuite();
  }
}