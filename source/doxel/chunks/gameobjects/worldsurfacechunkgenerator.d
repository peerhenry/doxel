import std.random;
import gfm.math;
import world, heightmap, blocks, chunk, chunkgameobject, chunkobjectfactory;

class WorldSurfaceChunkGenerator
{
  HeightMap heightMap;
  World world;
  ChunkObjectFactory chunkObjectFactory;

  this(World world, HeightMap heightMap, ChunkObjectFactory chunkObjectFactory)
  {
    this.world = world;
    this.heightMap = heightMap;
    this.chunkObjectFactory = chunkObjectFactory;
  }

  int hOffset = -10;

  /// The parameters are site indices relative to the center chunk.
  ChunkGameObject[] generateChunkColumn(vec2i centerRel_ij)
  {
    auto random = Random(unpredictableSeed);
    bool withTree = uniform(0,2, random) == 1;
    int tree_i = 4 + uniform(-2,3, random);
    int tree_j = 4 + uniform(-2,3, random);
    foreach(ii; 0..8)
    {
      foreach(jj; 0..8)
      {
        int block_i = (centerRel_ij.x)*8 + ii;
        int block_j = (centerRel_ij.y)*8 + jj;
        int h = heightMap.getHeight(block_i, block_j) + hOffset;
        world.setBlock(block_i, block_j, h, h<0 ? Block.SAND : Block.GRASS);
        world.setBlockColumn(block_i, block_j, h-1, 2, Block.DIRT);
        world.setBlockColumn(block_i, block_j, h-3, 2, Block.STONE);
        if(withTree && ii == tree_i && jj == tree_j && h > 0)
        {
          spawnTree(block_i, block_j, h+1, uniform(3,6,random));
          withTree = false;
        }
        if(h<-3+hOffset)
        {
          foreach(nn; h..(-2+hOffset))
          {
            world.setBlock(block_i, block_j, nn, Block.WATER);
          }
        }
      }
    }
    // Get the chunks that were created by adding the blocks and use them to make gameobjects
    Chunk[] newChunks = world.getNewChunks();
    ChunkGameObject[] chunkObjects;
    foreach(chunk; newChunks)
    {
      chunkObjects ~= chunkObjectFactory.createChunkObject(chunk);
    }
    // Clear the new chunks in world as they have been consumed.
    world.clearNewChunks();
    return chunkObjects;
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