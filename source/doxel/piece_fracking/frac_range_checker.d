import gfm.math;
import engine;
import piece, range_settings;

interface IFracRangeChecker
{
  @property int maxRank();
  @property RangeSetting topRankRange();

  // used for highest rank; pieces that enter or leave the stage
  bool withinLoadRange(vec2f position, DummyPiece piece);
  bool outsideUnloadRange(vec2f position, QueuePiece piece);

  bool withinFracRange(vec2f position, DummyPiece piece);
  bool outsideUnfracRange(vec2f position, QueuePiece piece);
}

class FracRangeChecker: IFracRangeChecker
{
  private{
    RangeSettings _rangeSettings;
  }

  @property int maxRank(){ return _rangeSettings.maxRank; }
  @property RangeSetting topRankRange(){ return _rangeSettings.topRankRange; }

  this(RangeSettings rangeSettings)
  {
    _rangeSettings = rangeSettings;
  }


  bool withinLoadRange(vec2f position, DummyPiece piece)
  {
    assert(piece.rank == maxRank);
    int sdcp = sqDistanceToPiece(position, piece);
    int rs = _rangeSettings.topRankRange.sqLoadRange;
    return sdcp < rs;
  }

  bool outsideUnloadRange(vec2f position, QueuePiece piece)
  {
    assert(piece.rank == maxRank);
    int sdcp = sqDistanceToPiece(position, piece);
    int rs = _rangeSettings.topRankRange.sqUnloadRange;
    return sdcp > rs;
  }


  bool withinFracRange(vec2f position, DummyPiece piece)
  {
    int sdcp = sqDistanceToPiece(position, piece);
    int rs = _rangeSettings.getSqLoadRange(piece.rank);
    return sdcp < rs;
  }

  bool outsideUnfracRange(vec2f position, QueuePiece piece)
  {
    int sdcp = sqDistanceToPiece(position, piece);
    int rs = _rangeSettings.getSqUnloadRange(piece.rank);
    return sdcp > rs;
  }


  private static int sqDistanceToPiece(vec2f position, Piece piece)
  {
    return sqDist(vec2i(cast(int)position.x, cast(int)position.y), piece);
  }

  private static int sqDist(vec2i point, Piece piece)
  {
    int sqd = 0;
    if( point.x < piece.x ) sqd += sqDist(point.x, piece.x);
    if( point.x > piece.x + piece.w ) sqd += sqDist(point.x, piece.x + piece.w);
    if( point.y < piece.y ) sqd += sqDist(point.y, piece.y);
    if( point.y > piece.y + piece.h ) sqd += sqDist(point.y, piece.y + piece.h);
    return sqd;
  }

  private static int sqDist(int a, int b)
  {
    int t = a-b;
    return t*t;
  }

  unittest{
    import testrunner;
    runsuite("frac_range_checker", delegate void(){

      runtest("sqDist", delegate void(){
        auto r = sqDist(3,5);
        assertEqual(4, r);
      });

      runtest("withinFracRange", delegate void(){
        // arrange
        RangeSettings settings = new RangeSettings( [ RangeSetting(0, 32, 42) ] );
        auto checker = new FracRangeChecker(settings);
        auto piece = new DummyPiece();
        piece.rank = 1;
        piece.x = 0;
        piece.y = 0;
        piece.w = 32;
        piece.h = 32;
        // act
        bool result1 = checker.withinFracRange(vec2f(4,4), piece);
        // assert
        assertEqual(true, result1);
      });

      runtest("withinFracRange outside range", delegate void(){
        // arrange
        RangeSettings settings = new RangeSettings( [ RangeSetting(0, 32, 42) ] );
        auto checker = new FracRangeChecker(settings);
        auto piece = new DummyPiece();
        piece.rank = 1;
        piece.x = 0;
        piece.y = 0;
        piece.w = 32;
        piece.h = 32;
        // act
        bool result2 = checker.withinFracRange(vec2f(-33,4), piece);
        // assert
        assertEqual(false, result2);
      });

      runtest("sqDistanceToPiece", delegate void(){
        // arrange
        RangeSettings settings = new RangeSettings( [ RangeSetting(0, 32, 42) ] );
        auto checker = new FracRangeChecker(settings);
        auto piece = new DummyPiece();
        piece.rank = 1;
        piece.x = 0;
        piece.y = 0;
        piece.w = 32;
        piece.h = 32;
        // act
        int sqDistance = checker.sqDistanceToPiece(vec2f(4,4), piece);
        // assert
        assertEqual(0, sqDistance);
      });

      runtest("sqDist should be 0 inside piece", delegate void(){
        // arrange
        RangeSettings settings = new RangeSettings( [ RangeSetting(0, 32, 42) ] );
        auto checker = new FracRangeChecker(settings);
        auto piece = new DummyPiece();
        piece.rank = 1;
        piece.x = 0;
        piece.y = 0;
        piece.w = 32;
        piece.h = 32;
        // act
        int result = checker.sqDist(vec2i(4, 4), piece);
        // assert
        assertEqual(0, result);
      });

    });
  }
}