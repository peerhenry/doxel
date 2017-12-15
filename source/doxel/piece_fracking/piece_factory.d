import std.math:pow;
import gfm.math:vec2i;
import piece, chunk, worldsettings, chunkscene;

class PieceFactory
{
  private{
    ChunkScene _standard;
    ChunkScene _skeletor;
  }

  this(ChunkScene standard, ChunkScene skeletor)
  {
    _standard = standard;
    _skeletor = skeletor;
  }

  ChunkScene[] getScenes(int rank)
  {
    return [_standard, _skeletor];
  }

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
    newPiece.rank = parent.rank - 1;
    newPiece.parent = parent;
    int size = pow(2, newPiece.rank);
    newPiece.x = site.x * size * regionWidth;
    newPiece.y = site.y * size * regionLength;
    newPiece.w = size * regionWidth;
    newPiece.h = size * regionLength;
    if(parent !is null)
    {
      newPiece.x += parent.x;
      newPiece.y += parent.y;
    }
    return newPiece;
  }

  QueuePiece create(DummyPiece dummy)
  {
    QueuePiece result = new QueuePiece(getScenes(dummy.rank));
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

    runtest("piece position rank 0 site (0,1) with parent @ (-1,-2)", delegate void(){
      DummyPiece parent = PieceFactory.createDummy(1, vec2i(-1,-2));
      DummyPiece piece = PieceFactory.createDummy(parent, vec2i(0,1));
      assertEqual(-1*2*regionWidth, piece.x, "piece.x");
      assertEqual(-2*2*regionLength + regionLength, piece.y, "piece.y");
    });

    runtest("piece position from rank 0 to 2 with sites (0,1), (1,0), (-1,-3)", delegate void(){
      DummyPiece parent2 = PieceFactory.createDummy(2, vec2i(-1,-3));
      DummyPiece parent1 = PieceFactory.createDummy(parent2, vec2i(1,0));
      DummyPiece piece = PieceFactory.createDummy(parent1, vec2i(0,1));
      assertEqual(-1*4*regionWidth + 2*regionWidth, piece.x, "piece.x");
      assertEqual(-3*4*regionLength + regionLength, piece.y, "piece.y");
    });

  });
}