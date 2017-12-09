
import doxel_world, chunkscene;

class WaterSceneChunkValidator : ISceneChunkValidator
{
  bool areValid(Chunk[] chunks)
  {
    foreach(chunk; chunks)
    {
      if(chunk.hasWater) return true;
    }
    return false;
  }
}