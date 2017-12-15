import piece, piece_queue_provider;

class PieceScene
{
  private{
    PieceQueueProvider _provider;
    QueuePiece[] _pieces;
  }

  this(PieceQueueProvider queueProvider)
  {
    _provider = queueProvider;
  }

  void update(){
    // if cam is away from center by d, get new queue...
    _pieces = _provider.getNewQueue();
    foreach(piece; _pieces)
    {
      // get heights
      // get chunks
      // make models
    }
  }
}