import std.array, std.conv, std.math:floor;
import gfm.math:vec2i;
import height_map_settings;

class MapSiteCalculator
{
  static:
  int cellSiteToIndex(vec2i cellSite) pure
  {
    return cellSite.x + mapCellWidth * cellSite.y;
  }

  vec2i[int] toMapSite(int i, int j)
  {
    vec2i[int] result;
    rec(result, 0, vec2i(i,j));
    return result;
  }

  private void rec(ref vec2i[int] mapSite, int rank, vec2i site) pure
  {
    mapSite[rank] = siteModulo(site);
    if(site.x >= mapCellWidth || site.y >= mapCellLength || site.x < 0 || site.y < 0)
    {
      vec2i nextSite = cellCenter + vec2i(
        cast(int)floor((cast(float)site.x)/mapCellWidth),
        cast(int)floor((cast(float)site.y)/mapCellLength)
      );
      rec(mapSite, rank+1, nextSite);
    }
    else if(rank == 0) // at least add rank 1
    {
      rec(mapSite, rank+1, cellCenter);
    }
  }
  
  pure vec2i siteModulo(vec2i site)
  {
    vec2i newSite = site;
    mixin(generateLoopCode!("newSite[@] = newSite[@] % mapCellSize[@]; if(newSite[@] < 0) newSite[@] += mapCellSize[@];", 2));
    return newSite;
  }

  // Speed-up CTFE conversions
  private string ctIntToString(int n) pure nothrow
  {
    static immutable string[16] table = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    if (n < 10)
        return table[n];
    else
        return to!string(n);
  }

  private string generateLoopCode(string formatString, int N)() pure nothrow
  {
    string result;
    for (int i = 0; i < N; ++i)
    {
      string index = ctIntToString(i);
      // replace all @ by indices
      result ~= formatString.replace("@", index);
    }
    return result;
  }

  unittest{
    import testrunner;

    beginSuite("MapSiteCalculator");

    runtest("toMapSite(mapCellWidth, mapCellLength)", delegate void(){
      // act
      vec2i[int] mapSite = toMapSite(mapCellWidth, mapCellLength);
      // assert
      assertEqual(vec2i(0,0), mapSite[0]);
      assertEqual(vec2i(cellCenter.x+1,cellCenter.y+1), mapSite[1]);
      assert((2 in mapSite) is null);
    });

    runtest("toMapSite(0, 0)", delegate void(){
      // act
      vec2i[int] mapSite = toMapSite(0, 0);
      // assert
      assertEqual(vec2i(0,0), mapSite[0]);
      assertEqual(cellCenter, mapSite[1]);
      assert((2 in mapSite) is null);
    });

    runtest("toMapSite(-10, 0)", delegate void(){
      // act
      vec2i[int] mapSite = toMapSite(-10, 0);
      // assert
      vec2i exp = vec2i(mapCellWidth-(10%mapCellWidth),0);
      assertEqual(exp, mapSite[0]);
      assertEqual(cellCenter + vec2i(cast(int)floor(-10.0/mapCellWidth),0), mapSite[1]);
      assert((2 in mapSite) is null);
    });

    runtest("toMapSite(-mapCellWidth, -mapCellLength)", delegate void(){
      // act
      vec2i[int] mapSite = toMapSite(-mapCellWidth, -mapCellLength);
      // assert
      assertEqual(vec2i(0,0), mapSite[0]);
      assertEqual(cellCenter-vec2i(1,1), mapSite[1]);
      assert((2 in mapSite) is null);
    });

    runtest("toMapSite(cellCenter.x, cellCenter.y)", delegate void(){
      // act
      vec2i[int] mapSite = toMapSite(cellCenter.x, cellCenter.y);
      // assert
      assertEqual(cellCenter, mapSite[0]);
      assertEqual(cellCenter, mapSite[1]);
      assert((2 in mapSite) is null);
    });

    endSuite();
  }
}