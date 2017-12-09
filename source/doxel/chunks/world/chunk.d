import std.math;
import gfm.math;
import doxel_world;

class Chunk: BaseRegion, IChunk
{
  private World world;
  Block[regionCount] blocks;
  private vec3i[int] worldSite;
  private int visibleBlockCounter;
  @property bool hasAnyVisisbleBlocks() { return visibleBlockCounter > 0; }

  this(World world, IRegionContainer container, vec3i site)
  {
    assert(world !is null);
    assert(container !is null);
    assert(container.getRank() == 2);
    super(1, site);
    this.world = world;
    this.container = container;
    container.addRegion(this);
    worldSite = buildWorldSite();
  }

  private vec3i[int] buildWorldSite()
  {
    assert(worldSite == null);
    vec3i[int] newWorldSite;
    newWorldSite[1] = site;
    auto nextContainer = this.container;
    while(nextContainer !is null)
    {
      newWorldSite[nextContainer.getRank()] = nextContainer.getSite();
      nextContainer = nextContainer.getContainer();
    }
    return newWorldSite;
  }

  bool isPulp(){return false;}

  /// Beware, the coordinates must be in bounds: 0<=i<8, 0<=j<8, 0<=k<4
  Block getBlock(int i, int j, int k)
  {
    int index = calculator.siteToIndex(i,j,k);
    return blocks[index];
  }

  private bool isVisible(Block block)
  {
    return !(block == Block.EMPTY || block == block.PULP);
  }

  void setBlock(int i, int j, int k, Block block)
  {
    int index = calculator.siteToIndex(i,j,k);
    Block oldBlock = blocks[index];
    if(isVisible(block))
    {
      if(!isVisible(oldBlock)) visibleBlockCounter++;
    }
    else
    {
      if(isVisible(oldBlock)) visibleBlockCounter--;
    }
    blocks[index] = block;
  }

  void setAllBlocks(Block block)
  {
    if(block != Block.PULP && block != Block.EMPTY) visibleBlockCounter = regionCount;
    blocks[] = block;
  }

  vec3i[int] getWorldSite()
  {
    return worldSite;
  }

  // obsolete?
  /*vec3i getGlobalSite()
  {
    return SiteCalculator.toGlobalSite(getWorldSite());
  }*/

  /// Gets position relative to world origin
  vec3f getPosition()
  {
    vec3i[int] worldSiteRef = world.getWorldSiteOrigin();
    return getPositionRelativeTo(worldSiteRef);
  }

  /// get this chunks position relative to given chunk.
  vec3f getPositionRelativeTo(Chunk chunk)
  {
    return getPositionRelativeTo(chunk.getWorldSite());
  }

  /// get this chunks position relative to a given worldsite.
  vec3f getPositionRelativeTo(vec3i[int] worldSiteRef)
  {
    return calculator.worldSiteRelativeTo(worldSite, worldSiteRef);
  }
}

unittest
{
  import testrunner;
  import sides;

  beginSuite("Chunk");

  runtest("Chunk position relative to itself is zero", delegate void() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(1,1,1));
    // act
    vec3f d = chunk.getPositionRelativeTo(chunk);
    // assert
    assert(d.x < 0.01);
    assert(d.y < 0.01);
    assert(d.z < 0.01);
  });

  runtest("Chunk position relative to ds=(1,1,1) will return (w,l,h)", delegate void() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(1,1,1));
    Chunk chunk2 = new Chunk(world, world.topRegion, vec3i(2,2,2));
    // act
    vec3f d = chunk2.getPositionRelativeTo(chunk);
    // assert
    assert(d.x == regionWidth);
    assert(d.y == regionLength);
    assert(d.z == regionHeight);
  });

  runtest("Chunk constructor gets assigned container", delegate void(){
    // arrange
    World world = new World();
    auto reg1 = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg = cast(IRegionContainer)world.getCreateAdjacentRegion(reg1, BottomDetails);
    Chunk chunk = new Chunk(world, reg, vec3i(2,2,1));
    // act
    IRegionContainer result = chunk.getContainer();
    // assert
    assertEqual(reg, result);
  });

  runtest("Chunk.getWorldSite() of two regions down", delegate void(){
    // arrange
    World world = new World();
    auto reg1 = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg = cast(IRegionContainer)world.getCreateAdjacentRegion(reg1, BottomDetails);
    Chunk chunk = new Chunk(world, reg, vec3i(2,2,1));
    // act
    vec3i[int] result = chunk.getWorldSite();
    // assert
    assert((2 in result) !is null);
    assertEqual(vec3i(2,2,1), result[1]);
    assertEqual(regionCenter - vec3i(0,0,2), result[2]);
  });

  runtest("Chunk position relative to adjacent chunk in other region", delegate void() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(0,0,0));
    Chunk chunk2 = cast(Chunk) (world.getCreateAdjacentRegion(chunk, BottomDetails));
    // act
    vec3f d = chunk2.getPositionRelativeTo(chunk);
    // assert
    assertEqual(0, d.x);
    assertEqual(0, d.y);
    assertEqual(-regionHeight, d.z);
  });

  runtest("Chunk position relative chunk, two regions down", delegate void() {
    // arrange
    World world = new World();
    auto reg1 = world.topRegion;
    auto regt = world.getCreateAdjacentRegion(world.topRegion, BottomDetails);
    IRegionContainer reg2 = cast(IRegionContainer)world.getCreateAdjacentRegion(regt, BottomDetails);
    Chunk chunk = new Chunk(world, reg1, vec3i(2,2,3));
    Chunk chunk2 = new Chunk(world, reg2, vec3i(2,2,1));
    // act
    vec3f d = chunk.getPositionRelativeTo(chunk2);
    // assert
    assertEqual(0, d.x);
    assertEqual(0, d.y);
    assertEqual((3 + regionHeight-1)*regionHeight + regionHeight*regionHeight, d.z);
  });

  runtest("identical to two regions down, but with world site", delegate void() {
    // arrange
    World world = new World();
    Chunk chunk = new Chunk(world, world.topRegion, vec3i(2,2,3));
    // act
    vec3f d = chunk.getPositionRelativeTo([1: vec3i(2,2,1), 2: (regionCenter - vec3i(0,0,2))]);
    // assert
    assertEqual(0, d.x);
    assertEqual(0, d.y);
    assertEqual((3 + regionHeight-1)*regionHeight + regionHeight*regionHeight, d.z);
  });

  endSuite();
}