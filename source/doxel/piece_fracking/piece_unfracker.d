import std.math, std.array;
import gfm.math;
import engine;
import piece, piece_map, frac_range_checker, piece_factory, piece_unloader, worldsettings;

interface IPieceUnfracker
{
  void unFrac(QueuePiece piece);
}

class PieceUnfracker: IPieceUnfracker
{
  private IPieceUnloader _unloader;

  this(IPieceUnloader unloader)
  {
    _unloader = unloader;
  }

  void unFrac(QueuePiece piece)
  {
    //import std.stdio; writeln("UNFRACKING NOW"); // DEBUG
    foreach(child; piece.children)
    {
      _unloader.unloadPiece(child);
    }
    piece.children[] = null;
    piece.isFracked = false;
  }
}