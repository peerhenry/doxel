import std.math:floor;
import gfm.math;
import engine;
import limiter, piece, piece_queue_provider, height_provider, chunk_column_provider, doxel_world;

interface IQueueProcessor
{
  void setQueue(QueuePiece[] queue);
  void processQueue(vec2f position);
}

class QueueProcessor: IQueueProcessor
{
  private{
    IHeightProvider _heightGenerator;
    IChunkColumnProvider _chunkProvider;
    int _nextIndex = 0;
    Limiter _limiter = new Limiter(4);
    QueuePiece[] _queue = [];
  }

  this(IHeightProvider heightGenerator, IChunkColumnProvider chunkProvider)
  {
    _heightGenerator = heightGenerator;
    _chunkProvider = chunkProvider;
  }

  void setQueue(QueuePiece[] queue)
  {
    _queue = queue;
    _nextIndex = 0;
  }

  void processQueue(vec2f position)
  {
    if(_queue.length == 0) return;
    _limiter.reset();
    while(!_limiter.limitReached())
    {
      auto piece = _queue[_nextIndex];
      if(!piece.hasHeights) genHeights(piece);
      else if(!piece.hasChunks) setChunks(piece);
      else if(!piece.hasModel) piece.createModel();
      int modder = cast(int)_queue.length;
      _nextIndex = (_nextIndex+1)%modder;
      _limiter.increment();
    }
  }

  private void genHeights(QueuePiece piece)
  {
    // generate heights for piece
    foreach(i; piece.x .. piece.x + piece.w)
      foreach(j; piece.y .. piece.y + piece.h)
      {
        _heightGenerator.getHeight(i, j);
      }
    piece.hasHeights = true;
  }

  private void setChunks(QueuePiece piece)
  {
    int chunk_i_min = getChunkIndex(piece.x, regionWidth);
    int chunk_j_min = getChunkIndex(piece.y, regionLength);
    int chunk_i_max = getChunkIndex(piece.x + piece.w, regionWidth);
    int chunk_j_max = getChunkIndex(piece.y + piece.h, regionLength);
    Chunk[] chunks;
    foreach(i; chunk_i_min .. chunk_i_max)
      foreach(j; chunk_j_min .. chunk_j_max)
      {
        chunks ~= _chunkProvider.getColumn(vec2i(i,j));
      }
    piece.setChunks(chunks);
  }

  private int getChunkIndex(int blockIndex, int size)
  {
    return cast(int)floor((cast(float)blockIndex)/size);
  }

  unittest
  {
    import testrunner;

    runsuite("queue processor", delegate void(){

      runtest("processQueue with nothing", delegate void(){
        QueueProcessor p = new QueueProcessor(null, null);
        p.processQueue(vec2f(0,0));
      });

    });
  }
}