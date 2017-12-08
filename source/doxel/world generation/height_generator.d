import std.math;
import inoise;

class HeightGenerator
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

  int getMultiHeight(int x, int y)
  {
    //import std.math;
    int h = 0;
    foreach(i; 1..3)
    {
      float modi = pow(10,i);
      //float modi = i;
      float fx = (cast(float)x + 0.5)*modi/cellSize;
      float fy = (cast(float)y + 0.5)*modi/cellSize;
      float result = generator.noise(fx, fy);
      h += cast(int)(result*range/modi);
    }
    return h;
  }
}