import std.math, std.array;
import gfm.math;
import engine;
import piece, piece_map, frac_range_checker, piece_factory, worldsettings;

class PieceQueueProvider
{
  private{
    int _maxRank;
    int _maxRankSize;
    PieceMap _dic;
    Appender!(QueuePiece[]) _pieces;
    IFracRangeChecker _rangeChecker;
    PieceFactory _factory;
  }

  this(int maxRank, PieceFactory factory, IFracRangeChecker rangeChecker)
  {
    _maxRank = maxRank;
    _maxRankSize = pow(2, maxRank);
    _dic = new PieceMap(maxRank, factory);
    _rangeChecker = rangeChecker;
    _pieces = appender!(QueuePiece[])();
  }

  QueuePiece[] getNewQueue(vec2f position)
  {
    resetQueue();
    int icenter = cast(int)floor(position.x/(_maxRankSize*regionWidth));
    int jcenter = cast(int)floor(position.y/(_maxRankSize*regionLength));
    int imin = icenter-2;
    int imax = icenter+2;
    int jmin = jcenter-2;
    int jmax = jcenter+2;
    foreach(i; imin..imax)
      foreach(j; jmin..jmax)
      {
        DummyPiece bigPiece = _factory.createDummy(_maxRank, vec2i(i,j));
        frack(bigPiece);
      }
    return _pieces.data();
  }

  private void resetQueue()
  {
    _pieces.clear();
  }

  private void enqueue(QueuePiece piece)
  {
    _pieces ~= piece;
  }

  private void frack(DummyPiece piece)
  {
    if(piece.rank == 0 || !_rangeChecker.withinFracRange(piece)) appendPiece(piece);
    else{
      foreach(i; 0..2)
        foreach(j; 0..2)
        {
          DummyPiece smallerPiece = _factory.createDummy(piece, vec2i(i,j));
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
    QueuePiece newPiece = _dic.insert(dummy);
    if(newPiece.parent !is null && !newPiece.parent.isFracked) // DEBUG
    {
      import std.stdio; writeln("newPiece.parent !is null && !newPiece.parent.isFracked");
    }
    if(newPiece.parent !is null && !newPiece.parent.isFracked && newPiece.parent.hasModel)
    {
      newPiece.parent.destroyModel();
    }
    enqueue(newPiece);
  }

  private void appendExisting(QueuePiece piece)
  {
    if(!piece.isFracked) enqueue(piece);
    else if(_rangeChecker.outsideUnfracRange(piece))
    {
      unFrac(piece);
      enqueue(piece);
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

  unittest{
    import testrunner;
    runsuite("piece_queue_provider", delegate void(){

      class MockRangeCheckerTrue: IFracRangeChecker
      {
        bool withinFracRange(DummyPiece piece){ return true; }
        bool outsideUnfracRange(QueuePiece piece){ return true; }
      }

      class MockRangeCheckerFalse: IFracRangeChecker
      {
        bool withinFracRange(DummyPiece piece){ return false; }
        bool outsideUnfracRange(QueuePiece piece){ return false; }
      }

      runtest("appendExisting empty QueuePiece", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeCheckerFalse();
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(2, fac, checker);
        QueuePiece exp = new QueuePiece();
        // act
        provider.appendExisting(exp);
        // assert
        QueuePiece[] arr = provider._pieces.data();
        assertEqual(1, arr.length);
        assertEqual(exp, arr[0]);
      });

      runtest("appendExisting QueuePiece with children", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeCheckerFalse();
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(2, fac, checker);
        QueuePiece exp = new QueuePiece();
        exp.isFracked = true;
        exp.children = [new QueuePiece(), new QueuePiece(), new QueuePiece(), new QueuePiece()];
        // act
        provider.appendExisting(exp);
        // assert
        QueuePiece[] arr = provider._pieces.data();
        assertEqual(4, arr.length);
      });

      runtest("frack piece expect 4 children", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeCheckerTrue();
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(1, fac, checker);
        DummyPiece dummy = fac.createDummy(1, vec2i(1,2));
        // act
        provider.frack(dummy);
        // assert
        QueuePiece[] arr = provider._pieces.data();
        assertEqual(4, arr.length, "arr.length");
        QueuePiece result = provider._dic.retrieve(dummy);
        assertEqual(true, result.isFracked, "result.isFracked");
        assertEqual(vec2i(0,0), result.children[0].site);
        assertEqual(vec2i(0,1), result.children[1].site);
        assertEqual(vec2i(1,0), result.children[2].site);
        assertEqual(vec2i(1,1), result.children[3].site);
      });

    });
  }
}