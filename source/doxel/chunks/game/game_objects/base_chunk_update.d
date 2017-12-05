import engine;
abstract class BaseChunkUpdate : Updatable
{
  private static const LOAD_RANGE = 512;
  private static const LOAD_RANGE_SQUARED = LOAD_RANGE*LOAD_RANGE;
  private static const UNLOAD_RANGE_SQUARED = (LOAD_RANGE+50)*(LOAD_RANGE+50);
}