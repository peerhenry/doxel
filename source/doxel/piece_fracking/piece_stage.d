import std.math:floor;
import gfm.math;
import engine;
import piece, piece_queue_provider, height_provider, chunk_column_provider, doxel_world;

class PieceStage
{
  private{
    Camera _cam;
    PieceQueueProvider _provider;
    IHeightProvider _heightGenerator;
    ChunkColumnProvider _chunkProvider;
    vec2i _lastCam_ij;

    QueuePiece[] _pieces;
    int _nextIndex = 0;
  }

  this(Camera cam, PieceQueueProvider queueProvider, IHeightProvider heightGenerator, ChunkColumnProvider chunkProvider)
  {
    _cam = cam;
    _provider = queueProvider;
    _heightGenerator = heightGenerator;
    _chunkProvider = chunkProvider;
    _lastCam_ij = vec2i(9999,9999);
  }

  void update(){

    vec2i centerRel_ij = vec2i(
      cast(int)floor(_cam.x/regionWidth),
      cast(int)floor(_cam.y/regionLength)
    );

    if(centerRel_ij != _lastCam_ij && centerRel_ij.squaredDistanceTo(_lastCam_ij) > 4)
    {
      _pieces = _provider.getNewQueue(vec2f(_cam.x, _cam.y));
      _nextIndex = 0;
      _lastCam_ij = centerRel_ij;
      import std.stdio; writeln("_pieces length is now: ", _pieces.length);
    }

    updatePieces();
  }

  import limiter;
  Limiter _limiter = new Limiter(4);

  private void updatePieces()
  {
    _limiter.reset();
    while(!_limiter.limitReached())
    {
      auto piece = _pieces[_nextIndex];
      if(!piece.hasHeights) genHeights(piece);
      else if(!piece.hasChunks) setChunks(piece);
      else if(!piece.hasModel) piece.createModel();
      _nextIndex = (_nextIndex+1)%_pieces.length;
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
}