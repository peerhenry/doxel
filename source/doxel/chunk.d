import gfm.math;

import blocks;

class Chunk
{
  Block[256] blocks;

  /// Beware, the coordinates must be in bounds: 0<=i<8, 0<=j<8, 0<=k<4
  Block getBlock(int i, int j, int k)
  {
    int index = i + 8*j + 64*k;
    return blocks[index];
  }

  void setBlock(int i, int j, int k, Block block)
  {
    int index = i + 8*j + 64*k;
    blocks[index] = block;
  }

  /// converts array index to chunk site coordinate
  static vec3i indexToCoord(int index)
  {
    int i = index%8;
    int k = index/64;
    int j = (index-64*k)/8;
    return vec3i(i,j,k);
  }
}