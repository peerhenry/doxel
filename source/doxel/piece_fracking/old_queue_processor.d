import gfm.math;
import piece, queue_processor, frac_range_checker, piece_unfracker, piece_unloader;

class OldQueueProcessor: IQueueProcessor
{
  private{
    IFracRangeChecker _rangeChecker;
    IPieceUnfracker _unfracker;
    IPieceUnloader _unloader;

    vec2i _lastCam_ij;
    QueuePiece[] _oldQueue;
    bool _oldQueueProcessed;
    QueuePiece[] _pieces;
    int _nextIndex = 0;
    QueuePiece[] _queue;
  }

  this(IFracRangeChecker rangeChecker, IPieceUnfracker unfracker, IPieceUnloader unloader)
  {
    _rangeChecker = rangeChecker;
    _unfracker = unfracker;
    _unloader = unloader;
  }

  void setQueue(QueuePiece[] queue)
  {
    _queue = queue;
  }

  void processQueue(vec2f position)
  {
    foreach(piece; _queue)
    {
      if(piece !is null)
      {
        if(piece.isFracked)
        {
          if(_rangeChecker.outsideUnfracRange(position, piece)) _unfracker.unFrac(piece);
        }
        else if(piece.parent !is null)
        {
          if(_rangeChecker.outsideUnfracRange(position, piece.parent)) _unfracker.unFrac(piece.parent);
        }
        else if(piece.rank == _rangeChecker.maxRank && _rangeChecker.outsideUnloadRange(position, piece))
        {
          _unloader.unloadPiece(piece);
        }
      }
    }
  }
}