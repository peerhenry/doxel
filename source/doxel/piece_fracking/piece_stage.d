import std.math:floor;
import gfm.math;
import engine;
import piece, piece_queue_provider, frac_range_checker, piece_unfracker, queue_processor,
height_provider, chunk_column_provider, doxel_world;

class PieceStage
{
  private{
    Camera _cam;
    PieceQueueProvider _provider;
    IQueueProcessor _processor;
    IQueueProcessor _oldQueueProcessor;
    bool _oldQueueProcessed;
    vec2i _lastCam_ij;
    QueuePiece[] _pieces;
  }

  this(Camera cam, PieceQueueProvider queueProvider, IQueueProcessor queueProcessor, IQueueProcessor oldQueueProcessor)
  {
    _cam = cam;
    _provider = queueProvider;
    _processor = queueProcessor;
    _oldQueueProcessor = oldQueueProcessor;
    _lastCam_ij = vec2i(9999,9999);
  }

  void update()
  {
    vec2i centerRel_ij = vec2i(
      cast(int)floor(_cam.x/regionWidth),
      cast(int)floor(_cam.y/regionLength)
    );
    vec2f pos = vec2f(_cam.x, _cam.y);
    if(centerRel_ij != _lastCam_ij) // && centerRel_ij.squaredDistanceTo(_lastCam_ij) > 0.25)
    {
      _oldQueueProcessed = false;
      _oldQueueProcessor.setQueue(_pieces.dup);
      _pieces = _provider.getNewQueue(pos);
      _processor.setQueue(_pieces);
      _lastCam_ij = centerRel_ij;
      //import std.stdio; writeln("_pieces length is now: ", _pieces.length); // DEBUG
    }
    updatePieces(pos);
  }

  import limiter;
  Limiter _limiter = new Limiter(4);

  private void updatePieces(vec2f pos)
  {
    if(!_oldQueueProcessed){
      _oldQueueProcessor.processQueue(pos);
      _oldQueueProcessed = true;
    }
    _processor.processQueue(pos);
  }
}