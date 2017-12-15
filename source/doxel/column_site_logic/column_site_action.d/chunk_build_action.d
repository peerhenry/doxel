import std.random, std.math:floor;
import gfm.math;
import i_column_site_action, column_site_queue_item, doxel_world, height_provider;

class ChunkBuildAction: IColumnSiteAction
{
  private HeightProvider _heightProvider;
  private World _world;

  this(HeightProvider heightProvider, World world)
  {
    _heightProvider = heightProvider;
    _world = world;
  }

  void perform(ColumnSiteQueueItem qItem)
  {
    generateChunkColumn(qItem.site);
    qItem.state = ColumnSiteState.HAS_CHUNKS;
    qItem.chunks = _world.getNewChunks();
  }

  private void generateChunkColumn(vec2i centerRel_ij)
  {
    // set block site bounds
    int ii_min = (centerRel_ij.x)*regionWidth;
    int ii_max = ii_min + regionWidth;
    int jj_min = (centerRel_ij.y)*regionLength;
    int jj_max = jj_min + regionLength;

    // set tree spawn parameters
    auto random = Random(centerRel_ij.x + centerRel_ij.y);
    bool withTree = uniform(0, 2, random) == 1;
    int tree_i = ii_min + regionWidth/2 + uniform(-2, 3, random);
    int tree_j = jj_min + regionLength/2 + uniform(-2, 3, random);

    // get the lowest block in the chunk column
    int chunkColMin = 99999999;
    foreach(ii; ii_min..ii_max)
    {
      foreach(jj; jj_min..jj_max)
      {
        int next_h = _heightProvider.getHeight(ii, jj);
        if(next_h < chunkColMin) chunkColMin = next_h;
      }
    }
    int chunkColBottom = (cast(int)floor((cast(float)chunkColMin)/regionHeight))*regionHeight;

    // set surface blocks in the chunk column
    foreach(ii; ii_min..ii_max)
    {
      foreach(jj; jj_min..jj_max)
      {
        int h = _heightProvider.getHeight(ii, jj);
        int[4] h_enws = [
          _heightProvider.getHeight(ii+1, jj)
          , _heightProvider.getHeight(ii, jj+1)
          , _heightProvider.getHeight(ii-1, jj)
          , _heightProvider.getHeight(ii, jj-1)
        ];

        Block surface = h<1 ? Block.SAND : Block.GRASS;

        int adj_min = 9999999;
        foreach(adj_h; h_enws)
        {
          if(adj_h < adj_min) adj_min = adj_h;
        }
        int h_min; // h_min is the lowest visible block
        if(adj_min >= h-1)
        {
          // all blocks under this one in this chunk become blob
          h_min = h;
          _world.setBlock(ii, jj, h, surface);
        }
        else
        {
          h_min = adj_min+1;
          foreach(hi; h_min..h+1)
          {
            Block block = hi<h ? Block.DIRT : surface;
            if(hi<h-4) block = Block.STONE;
            _world.setBlock(ii, jj, hi, block);
          }
        }

        // fill the rest of the chunk to the bottom with pulp;
        if(h_min > chunkColBottom)
        {
          foreach(hi; chunkColBottom..h_min)
          {
            _world.setBlock(ii, jj, hi, Block.PULP);
          }
        }

        // spawn trees
        if(withTree && ii == tree_i && jj == tree_j && h > 1)
        {
          spawnTree(ii, jj, h+1, uniform(3,6,random));
          withTree = false;
        }

        // fill water
        if(h < -1)
        {
          foreach(nn; (h+1)..0)
          {
            _world.setBlock(ii, jj, nn, Block.WATER);
          }
        }
      }
    }
    // spawn a blob chunk underneath
    int lowestChunkZ = calculator.siteCompModulo( chunkColMin, regionHeight );
    vec3i chunkPulpSite = vec3i( centerRel_ij.x, centerRel_ij.y, lowestChunkZ-1 );
    //_world.createPulpChunk( chunkPulpSite );
  }

  void spawnTree(int i, int j, int k, int height)
  {
    foreach(ii; -1..2)
    {
      foreach(jj; -1..2)
      {
        foreach(kk; -1..1)
        {
          _world.setBlock(i + ii, j + jj, k + height + kk, Block.LEAVES);
        }
      }
    }
    // + cross at top of tree
    _world.setBlock(i -1, j, k + height + 1, Block.LEAVES);
    _world.setBlock(i, j, k + height + 1, Block.LEAVES);
    _world.setBlock(i + 1, j, k + height + 1, Block.LEAVES);
    _world.setBlock(i, j -1, k + height + 1, Block.LEAVES);
    _world.setBlock(i, j + 1, k + height + 1, Block.LEAVES);
    foreach(h; 0..height)
    {
      _world.setBlock(i,j,k+h,Block.TRUNK);
    }
  }
}