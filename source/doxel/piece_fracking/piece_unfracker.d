import std.math, std.array;
import gfm.math;
import engine;
import piece, piece_map, frac_range_checker, piece_factory, worldsettings;

interface IPieceUnfracker
{
  void unFrac(QueuePiece piece);
}

class PieceUnfracker: IPieceUnfracker
{
  void unFrac(QueuePiece piece)
  {
    //import std.stdio; writeln("UNFRACKING NOW"); // DEBUG
    foreach(child; piece.children)
    {
      if(child.hasModel) child.destroyModel();
      child.destroy();
    }
    piece.children[] = null;
    piece.isFracked = false;
  }
}