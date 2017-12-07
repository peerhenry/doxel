import std.container;
import engine;
import chunk, i_chunk_stage_object_factory, limiter;
class ChunkStage:Updatable
{
  private{
    DList!Updatable stageObjects;
    IChunkStageObjectFactory fac;
    Limiter modelLimiter;
  }

  this(IChunkStageObjectFactory fac, Limiter modelLimiter)
  {
    this.fac = fac;
    this.modelLimiter = modelLimiter;
  }

  void createStageObject(Chunk[] chunks)
  {
    stageObjects.insert(fac.createStageObject(chunks));
  }

  void update(double dt_ms)
  {
    modelLimiter.reset();
    foreach(m; stageObjects)
    {
      m.update(dt_ms);
    }
  }
}