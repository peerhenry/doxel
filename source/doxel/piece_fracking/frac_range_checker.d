import gfm.math:vec2i;
import engine;
import piece;

struct FracRange{
  int rank;
  int sqRange;
  int sqUnfracRange;
  this(int rank, int range, int unfracRange)
  {
    this.rank = rank;
    this.sqRange = range*range;
    this.sqUnfracRange = unfracRange*unfracRange;
  }
}

class FracRangeChecker
{
  private{
    Camera _cam;
    FracRange[] _fracRanges;
    FracRange _lowestFracRange;
    int _fr1s, _fr2s, _ufr1s, _ufr2s;
  }

  this(Camera cam, FracRange[] fracRanges)
  {
    _cam = cam;
    _fracRanges = fracRanges;
    _lowestFracRange = FracRange(99999, 1, 1);
    foreach(fr; fracRanges)
    {
      if(fr.rank < _lowestFracRange.rank) _lowestFracRange = fr;
    }
  }

  bool withinFracRange(DummyPiece piece)
  {
    int sdcp = sqDistCamPiece(_cam, piece);
    int rs = getSqFracRange(piece.rank);
    return sdcp < rs;
  }

  bool outsideUnfracRange(QueuePiece piece)
  {
    int sdcp = sqDistCamPiece(_cam, piece);
    int rs = getSqUnfracRange(piece.rank);
    return sdcp > rs;
  }

  private int getSqFracRange(int rank)
  {
    auto fracRange = getHighestRangeBelow(rank);
    return fracRange.sqRange;
  }

  private int getSqUnfracRange(int rank)
  {
    auto fracRange = getHighestRangeBelow(rank);
    return fracRange.sqUnfracRange;
  }

  private FracRange getHighestRangeBelow(int rank)
  {
    FracRange fracRange = _lowestFracRange;
    foreach(fr; _fracRanges)
    {
      if(fr.rank > fracRange.rank && fr.rank < rank) fracRange = fr;
    }
    return fracRange;
  }

  private static int sqDistCamPiece(Camera cam, Piece piece)
  {
    return sqDist(cast(vec2i)cam.position.xy, piece);
  }

  private static int sqDist(vec2i point, Piece piece)
  {
    int sqd = 0;
    if( point.x < piece.x ) sqd += sqDist(point.x, piece.x);
    if( point.x > piece.x ) sqd += sqDist(point.x, piece.x + piece.w);
    if( point.y < piece.y ) sqd += sqDist(point.y, piece.y);
    if( point.y > piece.y ) sqd += sqDist(point.y, piece.y + piece.h);
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

      runtest("getSqUnfracRange", delegate void(){
        // arrange
        FracRange fr1 = FracRange(0, 32, 42);
        FracRange fr2 = FracRange(2, 200, 250);
        FracRange[] fracRanges = [
          fr1,
          fr2
        ];
        auto checker = new FracRangeChecker(null, fracRanges);
        // act
        auto r1 = checker.getSqUnfracRange(3);
        auto r2 = checker.getSqUnfracRange(2);
        // assert
        assertEqual(fr2.sqUnfracRange, r1);
        assertEqual(fr1.sqUnfracRange, r2);
      });

      runtest("getSqFracRange", delegate void(){
        // arrange
        FracRange fr1 = FracRange(0, 32, 42);
        FracRange fr2 = FracRange(2, 200, 250);
        FracRange[] fracRanges = [
          fr1,
          fr2
        ];
        auto checker = new FracRangeChecker(null, fracRanges);
        // act
        auto r1 = checker.getSqFracRange(3);
        auto r2 = checker.getSqFracRange(2);
        // assert
        assertEqual(fr2.sqRange, r1);
        assertEqual(fr1.sqRange, r2);
      });

    });
  }
}