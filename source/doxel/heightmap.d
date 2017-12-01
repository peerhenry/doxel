import inoise;

class HeightMap
{
  private INoise generator;
  private int cellSize;
  private int range;

  this(INoise noiseGenerator, int cellSize, int range)
  {
    this.generator = noiseGenerator;
    this.cellSize = cellSize;
    this.range = range;
  }

  int getHeight(int x, int y)
  {
    float fx = (cast(float)x + 0.5)/cellSize;
    float fy = (cast(float)y + 0.5)/cellSize;
    float result = generator.noise(fx, fy);
    return cast(int)(result*range);
  }
}