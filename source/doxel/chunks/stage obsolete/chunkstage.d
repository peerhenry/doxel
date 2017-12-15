import std.container;
import engine;
import chunk, i_chunk_stage_object_factory, limiter, chunk_stage_world_generator;
class ChunkStage:Updatable
{
  private{
    DList!Updatable stageObjects;
    IChunkStageObjectFactory fac;
    Limiter modelLimiter;
    ChunkStageWorldGenerator generator;
  }

  this(IChunkStageObjectFactory fac, Limiter modelLimiter, ChunkStageWorldGenerator generator)
  {
    this.fac = fac;
    this.modelLimiter = modelLimiter;
    this.generator = generator;
  }

  void createStageObject(Chunk[] chunks)
  {
    stageObjects.insert(fac.createStageObject(chunks));
  }

  void update(double dt_ms)
  {
    modelLimiter.reset();
    generator.update(this);
    foreach(m; stageObjects)
    {
      m.update(dt_ms);
    }
  }
}