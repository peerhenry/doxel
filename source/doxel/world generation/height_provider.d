import gfm.math:vec2i;
import height_map, height_generator;

interface IHeightProvider 
{
  int getHeight(int i, int j);
}

class HeightProvider
{
  private HeightGenerator generator;
  private HeightMap heightMap;

  this(HeightGenerator generator, HeightMap heightMap)
  {
    this.generator = generator;
    this.heightMap = heightMap;
  }

  int getHeight(int i, int j)
  {
    // change to cell site
    // get heightcell
    // if null, generate heights and create heightcell, return height
    // else 
    return 0;
  }
}