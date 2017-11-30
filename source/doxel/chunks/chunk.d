import gfm.math;

import iregioncontainer, region, baseregion, blocks;

class Chunk: BaseRegion
{
  Block[256] blocks;

  this(IRegionContainer container, vec3i site)
  {
    super(1, site);
    this.container = container;
    container.addRegion(this);
  }

  this(IRegionContainer container, vec3i site, Block block)
  {
    super(1, site);
    this.container = container;
    blocks[] = block;
    container.addRegion(this);
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