import std.random;
import gfm.math;
import doxel_world, height_provider;

class WorldSurfaceGenerator
{
  private IHeightProvider heightProvider;
  private World world;
  private int seed;

  this(World world, IHeightProvider heightProvider, int seed)
  {
    this.world = world;
    heightProvider.setOffset(-10);
    this.heightProvider = heightProvider;
    this.seed = seed;
  }

  int hOffset = -10;
  
  /// The parameters are site indices relative to the center chunk.
  void generateChunkColumn(vec2i centerRel_ij)
  {
    auto random = Random(seed);
    bool withTree = uniform(0,2, random) == 1;
    int tree_i = 4 + uniform(-2,3, random);
    int tree_j = 4 + uniform(-2,3, random);
    foreach(ii; 0..regionWidth)
    {
      foreach(jj; 0..regionLength)
      {
        int block_i = (centerRel_ij.x)*regionWidth + ii;
        int block_j = (centerRel_ij.y)*regionLength + jj;

        int h = heightProvider.getHeight(block_i, block_j) + hOffset;
        int[4] h_enws = [
          heightProvider.getHeight(block_i+1, block_j)
          , heightProvider.getHeight(block_i, block_j+1)
          , heightProvider.getHeight(block_i-1, block_j)
          , heightProvider.getHeight(block_i, block_j-1)
        ];

        int adj_min = 9999999;
        foreach(adj_h; h_enws)
        {
          if(adj_h < adj_min) adj_min = adj_h;
        }
        int h_min;
        if(adj_min >= h)
        {
          // all blocks under this one in this chunk become blob
          h_min = h;
          world.setBlock(block_i, block_j, h, Block.GRASS);
        }
        else
        {
          h_min = adj_min;
          foreach(hi; 0..h - adj_min)
          {
            Block surface = h<hOffset ? Block.SAND : Block.GRASS;
            Block block = hi>0 ? Block.DIRT : surface;
            if(hi>4) block = Block.STONE;
            world.setBlock(block_i, block_j, h - hi, block);
          }
        }

        // fill the rest of the chunk to the bottom with pulp;
        int chunkBottom = calculator.siteCompModulo(h_min, regionHeight);
        int ctb = h_min-chunkBottom;
        if(h_min > chunkBottom)
        {
          foreach(hi; chunkBottom..h_min)
          {
            world.setBlock(block_i, block_j, chunkBottom + hi, Block.PULP);
          }
        }

        // spawn trees
        if(withTree && ii == tree_i && jj == tree_j && h > hOffset)
        {
          spawnTree(block_i, block_j, h+1, uniform(3,6,random));
          withTree = false;
        }

        // fill water
        if(h < hOffset-3)
        {
          foreach(nn; h..(-2+hOffset))
          {
            world.setBlock(block_i, block_j, nn, Block.WATER);
          }
        }
      }
    }
  }

  void spawnTree(int i, int j, int k, int height)
  {
    foreach(ii; -1..2)
    {
      foreach(jj; -1..2)
      {
        foreach(kk; -1..1)
        {
          world.setBlock(i + ii, j + jj, k + height + kk, Block.LEAVES);
        }
      }
    }
    // + cross at top of tree
    world.setBlock(i -1, j, k + height + 1, Block.LEAVES);
    world.setBlock(i, j, k + height + 1, Block.LEAVES);
    world.setBlock(i + 1, j, k + height + 1, Block.LEAVES);
    world.setBlock(i, j -1, k + height + 1, Block.LEAVES);
    world.setBlock(i, j + 1, k + height + 1, Block.LEAVES);
    foreach(h; 0..height)
    {
      world.setBlock(i,j,k+h,Block.TRUNK);
    }
  }
}