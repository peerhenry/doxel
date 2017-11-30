import gfm.math;

import iregion, region, baseregion, blocks;

class Chunk: BaseRegion
{
  Block[256] blocks;

  this(IRegion container, vec3i site)
  {
    super(1, site);
    this.container = container;
  }

  this()
  {
    super(1, vec3i(4,4,2));
  }

  this(Block block)
  {
    super(1, vec3i(4,4,2));
    blocks[] = block;
  }

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
}