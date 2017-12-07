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

vec3f getBlockColor(Block block)
{
  final switch(block)
  {
    case Block.EMPTY:
      return vec3f(0,0,0);
    case Block.GRASS:
      return vec3f(0.17,0.75,0.27);
    case Block.STONE:
      return vec3f(0.6,0.5,0.4);
    case Block.DIRT:
      return vec3f(0.6,0.4,0.1);
    case Block.SAND:
      return vec3f(0.8,0.8,0.55);
    case Block.TRUNK:
      return vec3f(0.6,0.4,0.1);
    case Block.LEAVES:
      return vec3f(0,0.55,0);
    case Block.WATER:
      return vec3f(0.5,0.6,0.95);
  }
}