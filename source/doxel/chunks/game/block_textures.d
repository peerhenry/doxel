import gfm.math;
import sides, blocks;

vec2i getAtlasij(Block block, Side side)
{
  final switch(block)
  {
    case Block.EMPTY:
      return vec2i(8, 8);
    case Block.GRASS:
      if(side == Side.Top) return vec2i(0, 0);
      if(side == Side.Bottom) return vec2i(2, 0);
      return vec2i(3, 0);
    case Block.STONE:
      return vec2i(1, 0);
    case Block.DIRT:
      return vec2i(2, 0);
    case Block.SAND:
      return vec2i(2, 1);
    case Block.TRUNK:
      if(side == Side.Top || side == Side.Bottom) return vec2i(5, 1);
      return vec2i(4, 7); // vec2i(4, 1)
    case Block.LEAVES:
      return vec2i(5, 3);
    case Block.WATER:
      return vec2i(15, 12);
  }
}