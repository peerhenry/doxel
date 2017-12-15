import std.math;
import gfm.math:vec2i;
import engine;
import piece, piece_map, frac_range_checker;

class PieceQueueProvider
{
  private{
    Camera _cam;
    int _maxRank;
    int _maxRankSize;
    PieceMap _dic;
    QueuePiece[] _pieces;
    FracRangeChecker _rangeChecker;
  }

  this(Camera cam, int maxRank)
  {
    _cam = cam;
    _maxRank = maxRank;
    _maxRankSize = pow(2, maxRank);
    _dic = new PieceMap(maxRank);
    FracRange[] ranges = [
      FracRange(0, 32, 42),
      FracRange(2, 200, 250)
    ];
    _rangeChecker = new FracRangeChecker(cam, ranges);
  }

  QueuePiece[] getNewQueue()
  {
    resetQueue();
    int icenter = cast(int)floor(_cam.x/_maxRankSize);
    int jcenter = cast(int)floor(_cam.y/_maxRankSize);
    int imin = icenter-1;
    int imax = icenter+2;
    int jmin = jcenter-1;
    int jmax = jcenter+2;
    foreach(i; imin..imax)
      foreach(j; jmin..jmax)
      {
        DummyPiece bigPiece = PieceFactory.createDummy(_maxRank, vec2i(i,j));
        frack(bigPiece);
      }
    return _pieces;
  }

  private void resetQueue()
  {
    _pieces[] = null;
  }

  private void enQueue(QueuePiece piece)
  {
    _pieces ~= piece;
  }

  private void frack(DummyPiece piece)
  {
    if(piece.rank == 0) appendPiece(piece);
    else if( !_rangeChecker.withinFracRange(piece) ) appendPiece(piece);
    else{
      foreach(i; 0..2)
        foreach(j; 0..2)
        {
          DummyPiece smallerPiece = PieceFactory.createDummy(piece, vec2i(i,j));
          frack(smallerPiece);
        }
    }
  }

  private void appendPiece(DummyPiece dummy)
  {
    QueuePiece piece = _dic.retrieve(dummy);
    if(piece !is null){
      appendExisting(piece);
    }
    else appendNew(dummy);
  }

  private void appendNew(DummyPiece dummy)
  {
    auto newPiece = _dic.insert(dummy);
    enQueue(newPiece);
  }

  private void appendExisting(QueuePiece piece)
  {
    if(piece.rank == 0 || !piece.isFracked) enQueue(piece);
    else if(_rangeChecker.outsideUnfracRange(piece))
    {
      unFrac(piece);
      enQueue(piece);
    }
    else { // append Children
      foreach(child; piece.children)
      {
        appendExisting(child);
      }
    }
  }

  private void unFrac(QueuePiece piece)
  {
    foreach(child; piece.children)
    {
      child.destroy();
    }
    piece.children[] = null;
    piece.isFracked = false;
  }

  private void register(DummyPiece piece)
  {
    _dic.insert(piece);
  }


}