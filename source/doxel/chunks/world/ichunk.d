import blocks, iregion;
interface IChunk: IRegion
{
  Block getBlock(int i, int j, int k);

  bool isPulp();
}