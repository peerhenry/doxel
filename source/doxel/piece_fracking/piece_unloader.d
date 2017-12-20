import piece, piece_map;

interface IPieceUnloader
{
  void unloadPiece(QueuePiece piece);
}

class PieceUnloader: IPieceUnloader
{
  private IPieceMap _pieceMap;

  this(IPieceMap pieceMap)
  {
    _pieceMap = pieceMap;
  }

  void unloadPiece(QueuePiece piece)
  {
    if(piece.isFracked)
    {
      foreach(child; piece.children) unloadPiece(child);
    }
    _pieceMap.remove(piece);
    if(piece.hasModel) piece.destroyModel();
    piece.destroy();
  }
}