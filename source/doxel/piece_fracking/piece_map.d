import gfm.math;
import piece;

class PieceMap
{
  private QueuePiece[int][int] _dic;
  private int _maxRank;

  this(int maxRank)
  {
    _maxRank = maxRank;
  }

  QueuePiece insert(DummyPiece dummy)
  {
    QueuePiece qPiece = PieceFactory.create(dummy);
    if(qPiece.rank == _maxRank) _dic[qPiece.site.x][qPiece.site.y] = qPiece;
    else{
      QueuePiece qParent = retrieve(dummy.parent);
      if(qParent is null) qParent = insert(dummy.parent);
      qPiece.parent = qParent;
      qParent.register(qPiece);
      qParent.isFracked = true;
    }
    return qPiece;
  }

  QueuePiece retrieve(DummyPiece dp)
  {
    if(dp.rank == _maxRank) return retrieveAtSite(dp.site);
    else{
      QueuePiece parent = retrieve(dp.parent);
      if(parent is null) return null;
      return parent.getChild(dp.site);
    }
  }

  private QueuePiece retrieveAtSite(vec2i site)
  {
    QueuePiece[int]* dic1 = site.x in _dic;
    if(dic1 is null) return null;
    QueuePiece* val = site.y in *dic1;
    if(val is null) return null;
    return *val;
  }

  unittest{
    import testrunner;

    runsuite("PieceMap", delegate void(){

      runtest("retrieve non existant", delegate void(){
        auto pm = new PieceMap(1);
        auto dp = PieceFactory.createDummy(1, vec2i(1,2));
        auto result = pm.retrieve(dp);
        assertEqual(null, result);
      });

      runtest("retrieveAtSite existant", delegate void(){
        // arrange
        auto pm = new PieceMap(1);
        vec2i site = vec2i(0,1);
        auto dummy = PieceFactory.createDummy(1, site);
        auto expect = PieceFactory.create(dummy);
        pm.insert(dummy);
        // act
        auto result = pm.retrieveAtSite(site);
        // assert
        assertEqual(expect.rank, result.rank);
        assertEqual(expect.site, result.site);
        assertEqual(expect.x, result.x);
        assertEqual(expect.y, result.y);
        assertEqual(expect.w, result.w);
        assertEqual(expect.h, result.h);
      });

      runtest("retrieve existant", delegate void(){
        // arrange
        auto pm = new PieceMap(1);
        auto dummy = PieceFactory.createDummy(1, vec2i(0,1));
        auto expect = PieceFactory.create(dummy);
        pm.insert(dummy);
        // act
        auto result = pm.retrieve(dummy);
        // assert
        assertEqual(expect.rank, result.rank);
        assertEqual(expect.site, result.site);
        assertEqual(expect.x, result.x);
        assertEqual(expect.y, result.y);
        assertEqual(expect.w, result.w);
        assertEqual(expect.h, result.h);
      });

      runtest("insert/retrieve lower rank", delegate void(){
        // arrange
        auto pm = new PieceMap(2);
        auto dummyParent = PieceFactory.createDummy(2, vec2i(0,1));
        auto dp = PieceFactory.createDummy(dummyParent, vec2i(1,0));
        auto expect = pm.insert(dp);
        // act
        auto result = pm.retrieve(dp);
        // assert
        assertEqual(expect, result);
      });

    });
  }
}