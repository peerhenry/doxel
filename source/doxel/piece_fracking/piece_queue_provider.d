import std.math, std.array;
import gfm.math;
import engine;
import piece, piece_map, frac_range_checker, piece_factory, piece_unfracker, worldsettings;

class PieceQueueProvider
{
  private{
    int _maxRank;
    int _maxRankWidth, _maxRankLength;
    IPieceMap _dic;
    Appender!(QueuePiece[]) _pieces;
    IFracRangeChecker _rangeChecker;
    IPieceUnfracker _unfracker;
    PieceFactory _factory;
    int _ibound, _jbound;
  }

  this(IPieceMap pieceMap, PieceFactory factory, IFracRangeChecker rangeChecker, IPieceUnfracker unfracker)
  {
    _maxRank = rangeChecker.maxRank;
    int maxRankFactor = pow(2, _maxRank);
    _maxRankWidth = maxRankFactor*regionWidth;
    _maxRankLength = maxRankFactor*regionLength;
    _dic = pieceMap;
    _rangeChecker = rangeChecker;
    _unfracker = unfracker;
    _pieces = appender!(QueuePiece[])();

    _ibound = cast(int)ceil((cast(float)_rangeChecker.topRankRange.loadRange)/_maxRankWidth);
    _jbound = cast(int)ceil((cast(float)_rangeChecker.topRankRange.loadRange)/_maxRankLength);

    assert(_ibound < 10 && _jbound < 10);
  }

  IPieceMap getPieceMap()
  {
    return _dic;
  }

  QueuePiece[] getNewQueue(vec2f position)
  {
    resetQueue();
    int icenter = cast(int)floor(position.x/(_maxRankWidth));
    int jcenter = cast(int)floor(position.y/(_maxRankLength));
    int imin = icenter - _ibound;
    int imax = icenter + _ibound;
    int jmin = jcenter - _jbound;
    int jmax = jcenter + _jbound;
    foreach(i; imin..imax)
      foreach(j; jmin..jmax)
      {
        DummyPiece bigPiece = _factory.createDummy(_maxRank, vec2i(i,j));
        if( _rangeChecker.withinLoadRange(position, bigPiece) ) frack(position, bigPiece);
      }
    return _pieces.data().dup;
  }

  private void resetQueue()
  {
    _pieces.clear();
  }

  private void enqueue(QueuePiece piece)
  {
    _pieces ~= piece;
  }

  private void frack(vec2f position, DummyPiece piece)
  {
    if(piece.rank == 0 || !_rangeChecker.withinFracRange(position, piece)) appendPiece(position, piece);
    else{
      foreach(i; 0..2)
        foreach(j; 0..2)
        {
          DummyPiece smallerPiece = _factory.createDummy(piece, vec2i(i,j));
          frack(position, smallerPiece);
        }
    }
  }

  private void appendPiece(vec2f position, DummyPiece dummy)
  {
    QueuePiece piece = _dic.retrieve(dummy);
    if(piece !is null){
      appendExisting(position, piece);
    }
    else appendNew(dummy);
  }

  private void appendNew(DummyPiece dummy)
  {
    bool wasFracked = false;
    if(dummy.parent !is null)
    {
      QueuePiece qParent = _dic.retrieve(dummy.parent);
      if(qParent !is null){
        wasFracked = qParent.isFracked;
        qParent.isFracked = true;
      }
    }

    QueuePiece newPiece = _dic.insert(dummy);
    if(newPiece.parent !is null && !wasFracked && newPiece.parent.hasModel)
    {
      newPiece.parent.destroyModel();
    }
    enqueue(newPiece);
  }

  private void appendExisting(vec2f position, QueuePiece piece)
  {
    if(!piece.isFracked) enqueue(piece);
    else if(_rangeChecker.outsideUnfracRange(position, piece))
    {
      _unfracker.unFrac(piece);
      enqueue(piece);
    }
    else { // append Children
      foreach(child; piece.children)
      {
        appendExisting(position, child);
      }
    }
  }

  private void register(DummyPiece piece)
  {
    _dic.insert(piece);
  }

  unittest{
    import testrunner;
    import rank_scenes, chunkscene, range_settings;

    runsuite("piece_queue_provider", delegate void(){

      /*class MockRangeChecker: IFracRangeChecker
      {
        private int _range;
        private bool _withinRange;
        private int _mr;
        @property int maxRank(){return _mr;}
        this(int maxRank, bool withinRange)
        {
          _mr = maxRank;
          _range = cast(int)ceil(1.5*pow(2, maxRank)*regionWidth);
          _withinRange = withinRange;
        }
        bool withinLoadRange(vec2f position, DummyPiece piece){ return true; }
        bool outsideUnloadRange(vec2f position, QueuePiece piece){ return false; }
        bool withinFracRange(vec2f pos, DummyPiece piece){ return _withinRange; }
        bool outsideUnfracRange(vec2f pos, QueuePiece piece){ return _withinRange; }
        @property RangeSetting topRankRange(){ return RangeSetting(_mr, _range, _range); }
      }

      class MockRankScenes: IRankScenes
      {
        IChunkScene[] getScenes(int rank)
        {
          return null;
        }
      }

      runtest("appendExisting empty QueuePiece", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(2, true);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        QueuePiece exp = new QueuePiece();
        // act
        provider.appendExisting(vec2f(0,0), exp);
        // assert
        QueuePiece[] arr = provider._pieces.data();
        assertEqual(1, arr.length);
        assertEqual(exp, arr[0]);
      });

      runtest("appendExisting QueuePiece with children", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(2, false);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        QueuePiece exp = new QueuePiece();
        exp.isFracked = true;
        exp.children = [new QueuePiece(), new QueuePiece(), new QueuePiece(), new QueuePiece()];
        // act
        provider.appendExisting(vec2f(0,0), exp);
        // assert
        QueuePiece[] arr = provider._pieces.data();
        assertEqual(4, arr.length);
      });

      runtest("frack piece expect 4 children", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(1, true);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        DummyPiece dummy = fac.createDummy(1, vec2i(1,2));
        // act
        provider.frack(vec2f(0,0), dummy);
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

      
      runtest("getNewQueue with MockRangeCheckerTrue", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(1, true);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        // act
        QueuePiece[] result = provider.getNewQueue( vec2f(0,0) );
        // assert
        //assertEqual(64, result.length);
        assertEqual(false, result[0].isFracked, "result[0].isFracked");
        assertEqual(true, result[0].parent.isFracked, "result[0].isFracked");
        assertEqual(vec2i(0,0), result[0].site, "result[0].site");
        assertEqual(vec2i(0,1), result[1].site, "result[1].site");
        assertEqual(vec2i(1,0), result[2].site, "result[2].site");
        assertEqual(vec2i(1,1), result[3].site, "result[3].site");
      });

      runtest("vec2i equality", delegate void(){
        assertEqual(vec2i(1,2), vec2i(1,2));
        assert(vec2i(1,2) == vec2i(1,2));
        assert(vec2i(1,2) is vec2i(1,2));
      });

      */

      /*runtest("getNewQueue at 0,0", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(1, true);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        // act
        QueuePiece[] result = provider.getNewQueue( vec2f(0,0) );
        // assert
        //assertEqual(16, result.length);
        assertEqual(vec2i(-2,-2), result[0].site, "result[0].site");
        assertEqual(vec2i(-2,-1), result[1].site, "result[1].site");
      });*/

      /*runtest("getNewQueue at -100,100", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(1, false);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        // act
        QueuePiece[] result = provider.getNewQueue( vec2f(0,0) );
        // assert
        assertEqual(16, result.length);
      });*/

      /*class MockRangeCheckerTest: IFracRangeChecker
      {
        private int _mr;
        @property int maxRank(){return _mr;}
        this(int maxRank)
        {
          _mr = maxRank;
        }
        bool withinLoadRange(vec2f position, DummyPiece piece){ return true; }
        bool outsideUnloadRange(vec2f position, QueuePiece piece){ return false; }
        bool withinFracRange(vec2f pos, DummyPiece piece){ return piece.x < 0; }
        bool outsideUnfracRange(vec2f pos, QueuePiece piece){ return piece.x > 10; }
        @property RangeSetting topRankRange(){ return RangeSetting(_mr, 100, 120); }
      }

      runtest("getNewQueue with MockRangeCheckerTest", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeCheckerTest(1);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        // act
        QueuePiece[] first = provider.getNewQueue( vec2f(0,0) );
        // assert
        assertEqual(40, first.length);
      });*/

      /*runtest("getNewQueue, frac with second call", delegate void(){
        // arrange
        IFracRangeChecker checker = new MockRangeChecker(1, true);
        PieceFactory fac = new PieceFactory(new MockRankScenes());
        PieceQueueProvider provider = new PieceQueueProvider(fac, checker, new PieceUnfracker());
        // act
        QueuePiece[] first = provider.getNewQueue( vec2f(0,0) );
        // assert
        //assertEqual(16, first.length);
        assertEqual(vec2i(-2,-2), first[0].site, "result[0].site");
        assertEqual(vec2i(-2,-1), first[1].site, "result[1].site");
        assertEqual(false, first[0].isFracked, "first[0].isFracked");

        // act
        provider._rangeChecker = new MockRangeChecker(1, true);
        QueuePiece[] second = provider.getNewQueue( vec2f(0,0) );
        // assert
        //assertEqual(64, second.length);
        assertEqual(false, second[0].isFracked, "second[0].isFracked");
        assertEqual(1, first[0].rank, "first[0].rank after second getNewQueue call.");
        assertEqual(first[0].site, second[0].parent.site, "second[0].parent.site");
        assertEqual(first[0], second[0].parent);

        assertEqual(true, first[0].isFracked, "first[0].isFracked");
      });*/

      // Need to be refactored using RangeSettings
      /*runtest("getNewQueue at 4,4", delegate void(){
        // arrange
        FracRange[] ranges = [ FracRange(0, 16, 32) ];
        IFracRangeChecker rangeChecker = new FracRangeChecker(ranges);
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(2, fac, rangeChecker, new PieceUnfracker());
        // act
        QueuePiece[] result = provider.getNewQueue( vec2f(4,4) );
        // assert
        assertEqual(40, result.length);
      });

      runtest("getNewQueue, second queue should not unfrack", delegate void(){
        // arrange
        FracRange[] ranges = [ FracRange(0, 16, 3*regionWidth) ];
        IFracRangeChecker rangeChecker = new FracRangeChecker(ranges);
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(1, fac, rangeChecker, new PieceUnfracker());
        // act
        QueuePiece[] first = provider.getNewQueue( vec2f(4, 4) );
        // assert
        assertEqual(28, first.length);

        // act
        QueuePiece[] second = provider.getNewQueue( vec2f(4 - 2*regionWidth, 4) );
        // assert
        assertEqual(34, second.length);
      });

      runtest("getNewQueue, second queue should unfrack", delegate void(){
        // arrange
        //FracRange[] ranges = [ FracRange(0, regionWidth, regionWidth+1) ];
        RangeSettings settings = new RangeSettings( RangeSetting(0, regionWidth, regionWidth+1), RangeSetting(1, 4*regionWidth, 5*regionWidth) );
        IFracRangeChecker rangeChecker = new FracRangeChecker(ranges);
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(1, fac, rangeChecker, new PieceUnfracker());
        // act
        QueuePiece[] first = provider.getNewQueue( vec2f(4, 4) );
        // assert
        assertEqual(28, first.length);

        // act
        QueuePiece[] second = provider.getNewQueue( vec2f(4 - 2*regionWidth, 4 - 2*regionWidth) );
        // assert
        assertEqual(28, second.length);
      });

      runtest("getNewQueue, second queue should unfrack 2", delegate void(){
        // arrange
        FracRange[] ranges = [ FracRange(0, 16, 42) ];
        IFracRangeChecker rangeChecker = new FracRangeChecker(ranges);
        PieceFactory fac = new PieceFactory(null, null);
        PieceQueueProvider provider = new PieceQueueProvider(1, fac, rangeChecker, new PieceUnfracker());
        // act
        QueuePiece[] first = provider.getNewQueue( vec2f(4, 4) );
        // assert
        assertEqual(28, first.length);

        // act
        QueuePiece[] second = provider.getNewQueue( vec2f(4 - 3*regionWidth, 4) );
        // assert
        assertEqual(28, second.length);
      });*/

    });
  }
}