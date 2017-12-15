import std.math:pow;
import gfm.math:vec2i;
import chunk, worldsettings;

abstract class Piece
{
  vec2i site;
  int rank;
  int x, y, w, h;
}

class DummyPiece: Piece
{
  DummyPiece parent;
}

class QueuePiece: Piece
{
  bool isFracked;
  QueuePiece parent;
  QueuePiece[4] children;

  QueuePiece getChild(vec2i site)
  {
    if(site.x == 0)
    {
      if(site.y == 0) return children[0];
      else return children[1];
    }
    else{
      if(site.x == 0) return children[2];
      else return children[3];
    }
  }

  void register(QueuePiece piece)
  {
    assert(piece.rank == this.rank - 1);
    if(piece.site.x == 0)
    {
      if(piece.site.y == 0) children[0] = piece;
      else children[1] = piece;
    }
    else{
      if(piece.site.x == 0) children[2] = piece;
      else children[3] = piece;
    }
  }
}

class PieceFactory
{
  static DummyPiece createDummy(int rank, vec2i site)
  {
    DummyPiece newPiece = new DummyPiece();
    newPiece.site = site;
    newPiece.rank = rank;
    int size = pow(2, rank);
    newPiece.x = site.x * size * regionWidth;
    newPiece.y = site.y * size * regionLength;
    newPiece.w = size * regionWidth;
    newPiece.h = size * regionLength;
    return newPiece;
  }

  static DummyPiece createDummy(DummyPiece parent, vec2i site)
  {
    DummyPiece newPiece = new DummyPiece();
    newPiece.site = site;
    newPiece.rank = parent.rank-1;
    newPiece.parent = parent;
    int size = pow(2, newPiece.rank);
    newPiece.x = site.x * size * regionWidth;
    newPiece.y = site.y * size * regionHeight;
    newPiece.w = size * regionWidth;
    newPiece.h = size * regionLength;
    DummyPiece np = parent;
    while(np !is null)
    {
      newPiece.x += np.x;
      newPiece.y += np.y;
      np = np.parent;
    }
    return newPiece;
  }

  static QueuePiece create(DummyPiece dummy)
  {
    QueuePiece result = new QueuePiece();
    result.x = dummy.x;
    result.y = dummy.y;
    result.w = dummy.w;
    result.h = dummy.h;
    result.rank = dummy.rank;
    result.site = dummy.site;
    result.isFracked = false;
    return result;
  }
}

unittest{
  import testrunner;
  runsuite("piece factory", delegate void(){

    runtest("piece size rank 0", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(0, vec2i(0,0));
      assertEqual(regionWidth, piece.w);
      assertEqual(regionLength, piece.h);
    });

    runtest("piece size rank 1", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(1, vec2i(0,0));
      assertEqual(2*regionWidth, piece.w);
      assertEqual(2*regionLength, piece.h);
    });

    runtest("piece size rank 2", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(2, vec2i(0,0));
      assertEqual(4*regionWidth, piece.w);
      assertEqual(4*regionLength, piece.h);
    });

    runtest("piece size rank 3", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(3, vec2i(0,0));
      assertEqual(8*regionWidth, piece.w);
      assertEqual(8*regionLength, piece.h);
    });

    runtest("piece position rank 0 site (0,0)", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(0, vec2i(0,0));
      assertEqual(0, piece.x);
      assertEqual(0, piece.y);
    });

    runtest("piece position rank 0 site (2,3)", delegate void(){
      DummyPiece piece = PieceFactory.createDummy(0, vec2i(2,3));
      assertEqual(2*regionWidth, piece.x);
      assertEqual(3*regionLength, piece.y);
    });

    runtest("piece position rank 0 site (0,1) with parent @ (2,3)", delegate void(){
      DummyPiece parent = PieceFactory.createDummy(1, vec2i(2,3));
      DummyPiece piece = PieceFactory.createDummy(parent, vec2i(0,1));
      assertEqual(2*2*regionWidth, piece.x, "piece.x");
      assertEqual(3*2*regionLength + regionLength, piece.y, "piece.y");
    });

  });
}