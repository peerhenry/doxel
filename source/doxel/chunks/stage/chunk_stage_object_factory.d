import engine;
import chunk, chunk_stage_object, i_chunk_stage_object_factory, limiter;

class ChunkStageObjectFactory: IChunkStageObjectFactory
{
  private{
    Camera cam;
    Zone[int] zones;
    Limiter modelLimiter;
  }

  this(Camera cam, Zone[int] zones, Limiter modelLimiter)
  {
    this.cam = cam;
    this.zones = zones;
    this.modelLimiter = modelLimiter;
    validateZones();
  }

  private void validateZones()
  {
    int nextIndex = 1;
    Zone* nextZone = nextIndex in zones;
    float lastLoadRange = float.max;
    while(nextZone !is null)
    {
      assert(nextZone.loadRange < nextZone.unloadRange);
      assert(nextZone.unloadRange < lastLoadRange);
      lastLoadRange = nextZone.loadRange;
      nextIndex++;
      nextZone = (nextIndex in zones);
    }
  }

  Updatable createStageObject(Chunk chunk)
  {
    return createStageObject([chunk]);
  }

  Updatable createStageObject(Chunk[] chunks)
  {
    return new ChunkStageObject(cam, zones, chunks.dup, modelLimiter);
  }
}

unittest
{
  import testrunner;
  runTest("Invalid load ranges are rejected in ChunkStageObjectFactory", delegate bool(){
    // arrange
    Zone[int] zones = [1: Zone(1,2,null), 2: Zone(1.5,4,null)];
    // act
    bool pass = false;
    try
    {
      new ChunkStageObjectFactory(null, zones, new Limiter(20));
    }
    catch(AssertError)
    {
      pass = true;
    }
    return pass;
  });
}