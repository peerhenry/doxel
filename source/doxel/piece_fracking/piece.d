import std.math:pow;
import gfm.math:vec2i;
import engine;
import chunk, worldsettings, chunkscene, chunk_scene_object;

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
  bool hasHeights;
  bool hasChunks;
  bool hasModel;
  private{
    Chunk[] _chunks;
    IChunkScene[] _scenes;
    SceneObject[] _sceneObjects;
  }

  this(){}

  this(IChunkScene[] scenes)
  {
    _scenes = scenes;
  }

  void setChunks(Chunk[] chunks){
    _chunks = chunks;
    hasChunks = true;
  }

  void createModel()
  {
    foreach(i, scene; _scenes)
    {
      _sceneObjects ~= scene.createSceneObject( _chunks );
    }
    hasModel = true;
  }

  void destroyModel()
  {
    foreach(i, scene; _scenes)
    {
      scene.remove(_sceneObjects[i]);
      _sceneObjects[i].destroy;
      _sceneObjects[i] = null;
    }
    hasModel = false;
  }

  QueuePiece getChild(vec2i site)
  {
    if(site.x == 0)
    {
      if(site.y == 0) return children[0];
      else return children[1];
    }
    else{
      if(site.y == 0) return children[2];
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
      if(piece.site.y == 0) children[2] = piece;
      else children[3] = piece;
    }
  }
}