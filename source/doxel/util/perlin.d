import std.math;
import gfm.math;
import inoise;

class Perlin: INoise
{
  private short[] perm = new short[p_supply.length];

  this()
  {
    this(0);
  }

  this(int seed)
  {
    perm[] = p_supply;
    if (seed==0) // random seed
    {
      auto rand = new Random();
      seed = uniform!int(rand);
    }
    auto rand = new Random(seed);

    // do 400 random swaps in the permutation array
    foreach(i; 0 .. 400)
    {
      int swapFrom = cast(int) uniform(0, perm.length, rand);
      int swapTo = cast(int) uniform(0, perm.length, rand);
      short temp = perm[swapFrom];
      perm[swapFrom] = perm[swapTo];
      perm[swapTo] = temp;
    }
  }

  /// for debugging purposes
  vec2f[4] getnodes(float x, float y)
  {
    int celli = fastfloor(x);
    int cellj = fastfloor(y);
    vec2f[4] result;
    result[0] = getGradient(celli, cellj);
    result[1] = getGradient(celli+1, cellj);
    result[2] = getGradient(celli, cellj+1);
    result[3] = getGradient(celli+1, cellj+1);
    return result;
  }

  float noise(float x, float y)
  {
    // make x and y floats in grid of 8x8
    int celli = fastfloor(x);
    int cellj = fastfloor(y);

    // calculate the four dot products
    float vbl = dotGridGradient(celli, cellj, x, y);
    float vbr = dotGridGradient(celli+1, cellj, x, y);
    float vtl = dotGridGradient(celli, cellj+1, x, y);
    float vtr = dotGridGradient(celli+1, cellj+1, x, y);

    // Interpolate between grid point gradients
    // NOTE: the interpolation has been switched;
    // IE. the amplitude for the topright node dotproduct is being used for the bottomleft node
    // This is necessary in order to get a smooth interpolation across cells, otherwise there will be abrupt changes across cell boundaries
    float dx = x - celli;
    float dy = y - cellj;
    float itop = lerp(vtl, vtr, dx);
    float ibottom = lerp(vbl, vbr, dx);
    return lerp(ibottom, itop, dy);
  }

  /// Linear interpolation
  /// Weight w should be in the range [0.0, 1.0]
  private float lerp(float a, float b, float w)
  {
    return a + w*(b-a);
  }

  private int hashCoordinate(int i, int j)
  {
    int hash = perm[(perm[i & 255] + j) & 255] & 15;
    return hash;
  }

  private vec2f getGradient(int node_i, int node_j)
  {
    int hash = hashCoordinate(node_i, node_j);
    return gradients[hash];
  }

  float dotGridGradient(int node_i, int node_j, float x, float y)
  {
    float dx = x - node_i;
    float dy = y - node_j;
    vec2f gradient = getGradient(node_i, node_j);
    return (dx*gradient.x + dy*gradient.y);
  }

  // This method is a *lot* faster than using (int)Math.floor(x)
  private static int fastfloor(float x)
  {
    int xi = cast(int)x;
    return x < xi ? xi-1 : xi;
  }

  // DATA

  // this contains all the numbers between 0 and 255, these are
  // put in a random order depending upon the seed
  private static const short[] p_supply = [
    151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
  ];

  // 16 unit vectors
  private static vec2f[] gradients = [
    vec2f(1,0), vec2f(-1,0), vec2f(0,1), vec2f(0,-1),
    vec2f(0.707,0.707), vec2f(-0.707,0.707), vec2f(0.707,-0.707), vec2f(-0.707,-0.707),
    vec2f(0.866, 0.5), vec2f(-0.866, 0.5), vec2f(0.866, -0.5), vec2f(-0.866, -0.5), 
    vec2f(0.5, 0.866), vec2f(-0.5, 0.866), vec2f(0.5, -0.866), vec2f(-0.5, -0.866)
  ];
}